extends Entity

var thrown_by = null

onready var shadow = $shadow
onready var sprite = $sprite

func _ready():
  var result = $attackbox.connect("attack_landed", self, "_attack_landed")
  assert(result == OK)


func state_default(delta):
  for i in get_slide_count():
    var collision = get_slide_collision(i)
    # if collision.normal == -movedir:
    if collision.collider is Entity:
      collision.collider.handle_attack($attackbox)
    recoil()
    break
  gravity_loop(delta)
  movement_loop()
  facing_loop()
  switch_anim("default")

func recoil():
  queue_free()

func _attack_landed(_hitbox):
  recoil()

func handle_vertical_offset(offset):
  .handle_vertical_offset(offset)
  sprite.position.y = -offset
