extends Entity

onready var MAX_SPEED = speed

const MAX_MOVETIME = 2.0
var movetime = 0.0

const MAX_PAUSETIME = 2.5
var pausetime = 0.0

const MAX_AGGROTIME = 2.0
var aggrotime = 0.0
var aggro_target = null
export(Color) var aggro_color = Color(1, 0.5, 0.5)

export(bool) var electrified = false

onready var shadow = $shadow
onready var sprite = $bbc_sprite/sprite

func get_speed():
  var result = speed
  if sink > 0 && vertical_pos < sink:
    result *= min(1 / sqrt(sink), 1.0)
  return result

func _ready():
  sprite.material = sprite.material.duplicate()
  pausetime = MAX_PAUSETIME * max(randf(), 0.5)

func _physics_process(_delta):
  if state != "attack":
    electrified = false
    $attackbox_shock.monitorable = false

func state_default(delta):
  # modulate = Color(1, 1, 1)
  sprite.material.set_shader_param("modulate", Color(1, 1, 1));
  if pausetime > 0:
    pausetime -= delta
    if pausetime <= 0:
      movedir = directions.all[randi() % directions.all.size()]
      speed = MAX_SPEED * max(randf(), 0.5)
      movetime = MAX_MOVETIME * max(randf(), 0.5)

  if movetime > 0:
    movetime -= delta
    if is_on_wall():
      movedir = directions.all[randi() % directions.all.size()]
    if movetime <= 0:
      if randf() < 0.5:
        state = "attack"
      movedir = directions.none
      pausetime = MAX_PAUSETIME * max(randf(), 0.125)

  gravity_loop(delta)
  movement_loop()
  damage_loop()

  if knocktime > 0:
    switch_anim("idle_s", false, true)
  else:
    if movedir.length_squared() > 0:
      switch_anim("walk_s", false, true)
    else:
      switch_anim("idle_s", false, true)


func state_attack(delta):
  movedir = directions.none
  gravity_loop(delta)
  movement_loop()
  damage_loop()
  switch_anim("attack_s", false, true)
  if !anim.is_playing():
    state = "default"

func state_aggro(delta):
  # modulate = aggro_color
  sprite.material.set_shader_param("modulate", aggro_color);
  gravity_loop(delta)
  movement_loop()
  damage_loop()
  aggrotime -= delta
  if aggrotime <= 0:
    state = "default"
    movetime = 0.0
    pausetime = 0.01
    return
  movetime -= delta
  if movetime <= 0 || is_on_wall():
    if aggro_target && aggro_target.get_ref():
      movedir = directions.closest(global_position.direction_to(aggro_target.get_ref().global_position))
    else:
      movedir = directions.all[randi() % directions.all.size()]
    movetime = MAX_MOVETIME * 0.25

  switch_anim("walk_s", false, true)

func knockback(dir, spd, time):
  .knockback(dir, spd, time)

func handle_attack(attack, hitbox = hitboxes[0]):
  if electrified && attack.entity && attack.entity.hitboxes.size() > 0:
    if anim.current_animation_position < 0.625:
      anim.seek(0.625, true)
      attack.entity.handle_attack($attackbox_shock)
  else:
    .handle_attack(attack, hitbox)

func attack_landed(attack, _hitbox):
  # if electrified:
  #   attack.entity.handle_attack($attackbox_shock, attack.entity.hitboxes[0])
  if health > 0:
    safetime = 0.5
    speed = MAX_SPEED
    movetime = MAX_MOVETIME * 0.5
    if attack.entity.get("thrown_by"):
      aggro_target = weakref(attack.entity.thrown_by)
    else:
      aggro_target = weakref(attack.entity)
    if aggro_target.get_ref():
      movedir = directions.closest(global_position.direction_to(aggro_target.get_ref().global_position))
    else:
      movedir = directions.closest(global_position.direction_to(attack.global_position))
    state = "aggro"
    aggrotime = MAX_AGGROTIME

func handle_death(attack, hitbox):
  state = "death"
  switch_anim("death", false, true)
  yield(anim, "animation_finished")
  .handle_death(attack, hitbox)

func handle_vertical_offset(offset):
  .handle_vertical_offset(offset)
  sprite.position.y = -offset
  sprite.material.set_shader_param("sink", -offset if offset < 0 else 0)