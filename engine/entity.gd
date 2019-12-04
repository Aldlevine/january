extends KinematicBody2D

class_name Entity

signal knockback_finished
signal attack_landed(attack, hitbox)

enum Team {
  None,
  Ally,
  Neutral,
  Enemy
}

export(Team) var team := Team.None

export var max_health := 1.0
onready var health: float = max_health

export var vertical_pos := 0.0 setget set_vertical_pos
export var gravity := 9.8
var vertical_velocity := 0.0

export var speed := 70.0 setget , get_speed
var velocity := Vector2()
var movedir := Vector2()
var facedir := Vector2.DOWN setget set_facedir

onready var water_depth := get_tree().get_root().find_node("water_depth", true, false)
var sink := 0.0 setget set_sink

var hitboxes := []
var attackboxes := []
onready var base_layer = collision_layer
onready var base_mask = collision_mask

var knockdir := Vector2()
var knockspeed := 0
var knocktime := 0.0
var knocktime_start := 0.0

var safetime := 0.0

export(float) var drop_chance := 0.25
export(Array, PackedScene) var drops

export var state := "default"

onready var anim = $AnimationPlayer

### ACCESSORS

func get_speed():
  return speed

func set_vertical_pos(pos):
  vertical_pos = pos
  if is_inside_tree():
    handle_vertical_offset(pos - sink)

func set_sink(amt):
  var prev = sink
  sink = amt
  var pos = vertical_pos - amt
  if vertical_pos > 0:
    self.vertical_pos += sink - prev
  elif is_inside_tree():
    handle_vertical_offset(pos)

func set_facedir(dir):
  if dir.length_squared() > 0:
    match dir:
      Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN: facedir = dir
      _:
        if dir.x != facedir.x && dir.y != facedir.y:
          match facedir:
            Vector2.LEFT, Vector2.RIGHT: facedir = Vector2(0, dir.y)
            Vector2.UP, Vector2.DOWN: facedir = Vector2(dir.x, 0)

### INITIALIZERS

### LOOPS

func _physics_process(delta):
  if knocktime > 0:
    knocktime -= delta
    if knocktime <= 0:
      emit_signal("knockback_finished")

  if safetime >= 0:
    safetime -= delta

  correct_data_loop()

  if has_state(state):
    callv(str("state_", state), [delta])

func correct_data_loop():
  if health > max_health: health = max_health
  if health < 0: health = 0

func movement_loop(round_position = true):
  var motion = Vector2()
  if knocktime > 0 && knocktime_start > 0:
    motion = knockdir.normalized() * knockspeed * knocktime / knocktime_start
  else:
    motion = movedir.normalized() * self.speed

  var old_velocity = velocity
  velocity = move_and_slide(motion)
  if round_position && (velocity == Vector2() || velocity.normalized() != old_velocity.normalized()):
    global_position = global_position.round()

func facing_loop():
  set_facedir(movedir)

func damage_loop():
  if safetime > 0:
    var dim = int(Engine.get_frames_drawn() / 4.0) % 2 == 0
    modulate.a = 0.25 if dim else 1.0
  else:
    modulate.a = 1.0
    for hitbox in hitboxes:
      if hitbox.monitoring:
        for area in hitbox.get_overlapping_areas():
          if area is Attackbox && area.entity != self:
            if hitbox.air && !area.air: continue
            handle_attack(area, hitbox)

func gravity_loop(delta):
  self.vertical_pos += vertical_velocity
  if vertical_pos > 0:
    # Scale gravity by 0.5 because we view the world at a 45 degree angle
    vertical_velocity -= gravity * 0.5 * delta
  if vertical_pos <= 0:
    vertical_velocity = 0.0
    vertical_pos = 0.0

  if water_depth:
    self.sink = water_depth.get_depth_at_point(global_position)

### CALLABLES

func is_player():
  return false

func has_state(st):
  return has_method(str("state_", st))

func switch_anim(animation, sync_with_current = false, unfaced = false):
  var facing = "" if unfaced else directions.v2s(facedir)
  var new_animation = animation if unfaced else str(animation, "_", facing)
  var current_animation = anim.assigned_animation
  if current_animation != new_animation:
    anim.play(new_animation)
    if sync_with_current && current_animation.begins_with(animation):
      var current_anim_pos = anim.current_animation_position
      anim.seek(current_anim_pos)

func knockback(direction, spd, time):
  knockdir = direction
  knockspeed = spd
  knocktime = time
  knocktime_start = time

func instance_scene(scene, pos = global_position):
  var new_scene = scene.instance()
  new_scene.global_position = pos
  get_parent().add_child(new_scene)
  return new_scene

### HANDLERS

func handle_vertical_offset(_offset):
  layer_shifter.shift_layer(self, vertical_pos)
  for box in hitboxes:
    layer_shifter.shift_layer(box, vertical_pos)
  for box in attackboxes:
    layer_shifter.shift_layer(box, vertical_pos)

func handle_attack(attack, hitbox = null):
  if hitbox == null:
    if hitboxes.size() == 0:
      return
    hitbox = hitboxes[0]
  if !check_attack(attack, hitbox):
    return
  if attack.has_method("check_attack") && !attack.check_attack(hitbox):
    return
  health -= compute_damage(attack, hitbox)
  attack.handle_hit(hitbox)
  attack_landed(attack, hitbox)
  emit_signal("attack_landed", attack, hitbox)
  play_hit_fx(attack, hitbox)
  if health <= 0:
    yield(get_tree(), "physics_frame")
    if knocktime > 0:
      yield(self, "knockback_finished")
    handle_death(attack, hitbox)

func check_attack(attack, _hitbox):
  if knocktime > 0: return false
  if team == Team.None || attack.entity.team == Team.None: return true
  if team == Team.Neutral: return false
  if team == attack.entity.team: return false
  return true

func attack_landed(_attack, _hitbox):
  pass

func play_hit_fx(_attack, _hitbox):
  if has_node("audio/hit"):
    $audio/hit.play()

func handle_death(_attack, _hitbox):
  handle_drop()
  queue_free()

func handle_drop():
  if randf() < drop_chance:
    if drops.size() > 0:
      var i = randi() % drops.size()
      if drops[i]: instance_scene(drops[i])

func compute_damage(attack, _hitbox):
  return attack.power
