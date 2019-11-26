extends Entity

var lifespan = 1.0
var lifetime = 0.0

var thrown_by = null

onready var max_speed = speed

func get_speed():
  var result = speed
  if sink > 0 && vertical_pos < sink:
    result *= min(1 / sqrt(sink), 1.0)
  return result

func _ready():
  $Sprite.material = $Sprite.material.duplicate()
  var result = $pickup.connect("pickup", self, "_handle_pickup")
  assert(result == OK)
  result = $attackbox.connect("attack_landed", self, "_attack_landed")
  assert(result == OK)

func state_default(delta):
  if movedir.length_squared() > 0:
    $shadow.visible = true
    for i in get_slide_count():
      var collision = get_slide_collision(i)
      if collision.normal == -movedir:
        recoil()
        break

    #air
    if sink == 0 || vertical_pos > sink:
      speed -= (speed * 1.5 * delta)
      switch_anim("default", false, true)
    #water
    elif sink > 0 && vertical_pos < sink:
      speed -= (speed * 3.0 * delta)
      if anim.is_playing():
        anim.stop()
        $Sprite.rotation_degrees = 0
    #ground
    if vertical_pos == 0:
      speed -= (speed * 3.0 * delta)
    if speed < 5:
      state = "pickup"
  elif anim.is_playing():
    anim.stop()
    $Sprite.rotation_degrees = 0
  gravity_loop(delta)
  movement_loop()

func state_pickup(_delta):
  movedir = Vector2()
  movement_loop()
  anim.stop()
  collision_layer = 0
  collision_mask = 0
  $Sprite.rotation = 0
  $pickup.monitorable = true
  $attackbox.monitorable = false
  $shadow.visible = true

func recoil():
  movedir = -movedir
  speed *= 0.25
  # max_speed *= 0.25

func handle_vertical_offset(offset):
  $Sprite.position.y = -offset
  $attackbox.position.y = -offset
  $shadow.self_modulate.a = lerp(1.0, 0.0, max(min(-offset / 6.0, 1.0), 0.0))
  $Sprite.material.set_shader_param("sink", -offset if offset < 0 else 0)

  if vertical_pos > 0:
    $attackbox.air = true
    $attackbox.set_collision_layer_bit(0, false)
    $attackbox.set_collision_mask_bit(0, false)
    set_collision_layer_bit(1, true)
    set_collision_mask_bit(1, true)
  else:
    $attackbox.air = false
    $attackbox.set_collision_layer_bit(0, true)
    $attackbox.set_collision_mask_bit(0, true)
    set_collision_layer_bit(1, false)
    set_collision_mask_bit(1, false)

func _handle_pickup(entity):
  if entity.is_player():
    entity.num_rocks += 1
    queue_free()

func _attack_landed(_hitbox):
  recoil()
  $attackbox.monitorable = false
