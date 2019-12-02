extends Entity

const PAUSETIME_MAX = 1.25
const PAUSETIME_RAND = 0.75
var pausetime = 0.0

const MAX_JUMPS = 5
var jumps = 0

onready var shadow = $shadow
onready var sprite = $bbc_sprite/sprite

func get_speed():
  var result = speed
  if sink > 0 && vertical_pos < sink:
    result *= min(1 / sqrt(sink * 0.5), 1.0)
  return result

func _ready():
  sprite.material = sprite.material.duplicate()

func state_default(delta):
  # if movetime <= 0 || is_on_wall():
    # movedir = [directions.n, directions.s, directions.e, directions.w][randi() % 4]
  if vertical_pos == 0:
    if jumps == 0:
      jumps = MAX_JUMPS
      state = "pause"
      movedir = Vector2()
      pausetime = PAUSETIME_MAX - randf() * PAUSETIME_RAND
    else:
      jump()
      jumps -= 1

  # else:
  #   movetime -= delta

  gravity_loop(delta)
  facing_loop()
  movement_loop()
  damage_loop()

  if movedir.length_squared() > 0:
    switch_anim("walk")
  else:
    switch_anim("idle")

func state_pause(delta):
  if pausetime <= 0:
    state = "default"
    jump()
  else:
    pausetime -= delta

  gravity_loop(delta)
  facing_loop()
  movement_loop()
  damage_loop()

func state_death(delta):
  gravity_loop(delta)

func jump():
  if is_on_wall():
    movedir = directions.closest(get_slide_collision(0).normal, ["n", "e", "s", "w"])
  else:
    movedir = [directions.n, directions.s, directions.e, directions.w][randi() % 4]
  vertical_velocity = 1.25


func handle_vertical_offset(offset):
  .handle_vertical_offset(offset)
  sprite.position.y = -offset
  shadow.scale = Vector2(1, 1) * (1 - max(offset, 0) / 32)
  sprite.material.set_shader_param("sink", -offset if offset < 0 else 0)

func attack_landed(_attack, _hitbox):
  if health > 0:
    safetime = 0.5

func handle_death(attack, hitbox):
  state = "death"
  switch_anim("death")
  yield(anim, "animation_finished")
  .handle_death(attack, hitbox)