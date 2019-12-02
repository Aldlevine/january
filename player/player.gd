extends Entity

class_name Player

signal show_thrown_item()
signal throw_item(dir)

export var strength := 1.0 setget, get_strength

var inputdir := Vector2()

var pain_meds := 0.0
var opti_meds := 0.0

var num_rocks := 0
var num_plasma_grenades := 3

var thrown_item = null

onready var shadow = $shadow
onready var sprite = $bbc_sprite/sprite

# onready var water_depth := get_tree().get_root().find_node("water_depth", true, false)
# var sink := 0.0 setget set_sink

### ACCESSORS

func get_strength():
  var result = strength
  if opti_meds > 0:
    result *= 2
  if pain_meds > 0:
    result *= 0.75
  return result

func get_speed():
  var result = speed
  if pain_meds > 0:
    result *= 0.875
  if opti_meds > 0:
    result *= 1.125
  if sink > 0 && vertical_pos < sink:
    result *= min(1 / sqrt(sink), 1.0)
  return result

### INITIALIZERS

func _ready():
  sprite.material = sprite.material.duplicate()
  $fx_bg.visible = true
  $fx_fg.visible = true
### LOOPS

func _physics_process(_delta):
  if state != "knife":
    $attackbox_knife.set_deferred("monitorable", false)

func input_loop():
  var west = Input.is_action_pressed("player_left")
  var east = Input.is_action_pressed("player_right")
  var north = Input.is_action_pressed("player_up")
  var south = Input.is_action_pressed("player_down")
  inputdir.x = -int(west) + int(east)
  inputdir.y = -int(north) + int(south)

func facing_loop():
  set_facedir(inputdir)

func move_controls_loop():
  if vertical_pos == 0:
    movedir = inputdir
  if Input.is_action_just_pressed("player_jump") && vertical_pos == 0:
    jump()

func attack_controls_loop():
  if Input.is_action_just_pressed("player_action_1"):
    knife()
  if Input.is_action_just_pressed("player_action_2"):
    rock()
    # gun()

func pickup_loop():
  if $hitbox.monitoring:
    for area in $hitbox.get_overlapping_areas():
      if area is Pickup:
        area.pickup(self)

func status_loop(delta):
  if opti_meds > 0:
    opti_meds -= delta
    var threshold = $fx_bg/opti_meds.material.get_shader_param("threshold");
    if threshold > 0.3:
      $fx_bg/opti_meds.material.set_shader_param("threshold", lerp(threshold, 0.3, delta * 2.0))
    threshold = $fx_fg/opti_meds.material.get_shader_param("threshold");
    if threshold > 0.4:
      $fx_fg/opti_meds.material.set_shader_param("threshold", lerp(threshold, 0.4, delta * 2.0))
  else:
    var threshold = $fx_bg/opti_meds.material.get_shader_param("threshold");
    if threshold < 1.0:
      $fx_bg/opti_meds.material.set_shader_param("threshold", lerp(threshold, 1.0, delta * 2.0))
    threshold = $fx_fg/opti_meds.material.get_shader_param("threshold");
    if threshold < 1.0:
      $fx_fg/opti_meds.material.set_shader_param("threshold", lerp(threshold, 1.0, delta * 2.0))

  if pain_meds > 0:
    pain_meds -= delta
    health += 0.1 * delta
    var threshold = $fx_bg/pain_meds.material.get_shader_param("threshold");
    if threshold > 0.3:
      $fx_bg/pain_meds.material.set_shader_param("threshold", lerp(threshold, 0.3, delta * 2.0))
    threshold = $fx_fg/pain_meds.material.get_shader_param("threshold");
    if threshold > 0.4:
      $fx_fg/pain_meds.material.set_shader_param("threshold", lerp(threshold, 0.4, delta * 2.0))
  else:
    var threshold = $fx_bg/pain_meds.material.get_shader_param("threshold");
    if threshold < 1.0:
      $fx_bg/pain_meds.material.set_shader_param("threshold", lerp(threshold, 1.0, delta * 2.0))
    threshold = $fx_fg/pain_meds.material.get_shader_param("threshold");
    if threshold < 1.0:
      $fx_fg/pain_meds.material.set_shader_param("threshold", lerp(threshold, 1.0, delta * 2.0))

# STATES

func state_default(delta):
  status_loop(delta)
  input_loop()
  move_controls_loop()
  movement_loop()
  gravity_loop(delta)
  facing_loop()
  attack_controls_loop()
  pickup_loop()
  damage_loop()
  if movedir.length_squared() == 0:
    switch_anim("idle")
  else:
    switch_anim("walk", true)

func state_knife(delta):
  if vertical_pos == 0:
    movedir = Vector2()
  status_loop(delta)
  gravity_loop(delta)
  movement_loop()
  pickup_loop()
  damage_loop()
  switch_anim("knife")
  if !anim.is_playing():
    state = "default"

func state_gun(delta):
  if vertical_pos == 0:
    movedir = Vector2()
  status_loop(delta)
  gravity_loop(delta)
  movement_loop()
  pickup_loop()
  damage_loop()
  switch_anim("gun")
  if !anim.is_playing():
    state = "default"

func state_throw(delta):
  if vertical_pos == 0:
    movedir = Vector2()
  status_loop(delta)
  gravity_loop(delta)
  input_loop()
  movement_loop()
  pickup_loop()
  damage_loop()
  switch_anim("throw")
  if !anim.is_playing():
    state = "default"
  if thrown_item && thrown_item.movedir == Vector2():
    thrown_item.global_position = $thrown_item_pos.global_position
    thrown_item.global_position.y = $thrown_item_pos.global_position.y - (vertical_pos - sink)

### ACTIONS

func jump():
  vertical_velocity = 1.5

func knife():
  state = "knife"

func gun():
  state = "gun"

func rock():
  if num_rocks > 0:
    throw(preload("res://throwables/rock/rock.tscn"))
    num_rocks -= 1

func plasma_grenade():
  if num_plasma_grenades > 0:
    throw(preload("res://throwables/plasma_grenade/plasma_grenade.tscn"))
    num_plasma_grenades -= 1

func throw(item):
  state = "throw"
  yield(self, "show_thrown_item")
  thrown_item = instance_scene(item, $thrown_item_pos.global_position)
  thrown_item.team = Team.Ally
  thrown_item.thrown_by = self
  thrown_item.global_position.y = $thrown_item_pos.global_position.y - (vertical_pos - sink)
  # thrown_item.vertical_pos = 2.0
  if facedir != directions.n:
    thrown_item.z_index = 1
  var throw_dir = yield(self, "throw_item")
  thrown_item.z_index = 0
  thrown_item.global_position = $thrown_item_pos.global_position
  # thrown_item.vertical_pos = 8.0 + vertical_pos - sink
  thrown_item.vertical_pos = 8.0 + vertical_pos
  thrown_item.sink = sink
  thrown_item.vertical_velocity = 0.5
  thrown_item.global_position.y += 5.0
  thrown_item.movedir = throw_dir
  thrown_item = null

### CALLABLES

func is_player():
  return true

func emit_throw_item(dir: Vector2):
  # if inputdir.length_squared() > 0 && abs(inputdir.angle_to(facedir)) < PI / 2.0:
  #   emit_signal("throw_item", (inputdir + facedir).normalized())
  # else:
  #   emit_signal("throw_item", facedir.normalized())
  emit_signal("throw_item", dir)

func emit_show_thrown_item():
  emit_signal("show_thrown_item")

### HANDLERS

func handle_vertical_offset(offset):
  .handle_vertical_offset(offset)
  sprite.position.y = -floor(offset)
  $fx_bg.position.y = -floor(offset)
  $fx_fg.position.y = -floor(offset)
  
  shadow.scale = Vector2(1, 1) * (1 - max(offset, 0) / 32)
  # $water_line.self_modulate.a = lerp(0.0, 1.0, min(-offset / 6.0, 1.0))
  # $shadow.self_modulate.a = lerp(1.0, 0.0, max(min(-offset / 6.0, 1.0), 0.0))
  sprite.material.set_shader_param("sink", -floor(offset) if offset < 0 else 0.0)

func attack_landed(_attack, _hitbox):
  if health > 0:
    safetime = 1.0

func compute_damage(attack, hitbox):
  var result = .compute_damage(attack, hitbox)
  if pain_meds > 0:
    result *= 0.5
  return result

# func check_attack(_attack, _hitbox):
#   return false

# func handle_death(_attack, _hitbox):
#   health = max_health
