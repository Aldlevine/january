extends Entity

var lifespan = 1.0
var lifetime = 0.0

var fuse_time = 1.0

var thrown_by = null

onready var max_speed = speed

func set_vertical_pos(pos):
  .set_vertical_pos(pos)
  $Sprite.position.y = -pos
  $attackbox.position.y = -pos

func _ready():
  # var result = $pickup.connect("pickup", self, "_handle_pickup")
  # assert(result == OK)
  var result = $attackbox.connect("attack_landed", self, "_attack_landed")
  assert(result == OK)

func gravity_loop(delta):
  .gravity_loop(delta)
  # self.vertical_pos += vertical_velocity
  if vertical_pos > 0:
    # vertical_velocity -= 0.98 * delta
    $attackbox.air = true
    $attackbox.set_collision_layer_bit(0, false)
    $attackbox.set_collision_mask_bit(0, false)
    set_collision_layer_bit(1, true)
    set_collision_mask_bit(1, true)
  if vertical_pos <= 0:
    # vertical_velocity = 0.0
    # vertical_pos = 0.0
    $attackbox.air = false
    $attackbox.set_collision_layer_bit(0, true)
    $attackbox.set_collision_mask_bit(0, true)
    set_collision_layer_bit(1, false)
    set_collision_mask_bit(1, false)

func state_default(delta):
  if lifetime >= lifespan:
    state = "detonate"
  if movedir.length_squared() > 0:
    $shadow.visible = true
    for i in get_slide_count():
      var collision = get_slide_collision(i)
      if collision.normal == -movedir:
        recoil()
        break
    lifetime += delta
    speed = (1 - (lifetime / lifespan)) * max_speed
  switch_anim("default", false, true)
  gravity_loop(delta)
  movement_loop()

func state_detonate(delta):
  fuse_time -= delta
  if fuse_time <= 0:
    $Particles2D.emitting = true
    # switch_anim("detonate", false, true)

func recoil():
  movedir = -movedir
  max_speed *= 0.25

func _attack_landed(_hitbox):
  recoil()
  $attackbox.monitorable = false
