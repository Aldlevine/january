extends Area2D

class_name Attackbox

signal attack_landed(hitbox)

enum AttackType {
  BLUNT = 1,
  SHARP = 2,
  FIRE = 4,
  ELECTRIC = 8,
}

export(AttackType, FLAGS) var type := 0
export(float) var power := 1.0 setget , get_power
export(bool) var air := false

export(int) var knockspeed := 200
export(float) var knocktime := 0.2

onready var entity = get_parent()
onready var base_layer = collision_layer
onready var base_mask = collision_mask

onready var ray2d = entity.get_node("ray2d") if entity && entity.has_node("ray2d") else null

func _ready():
  entity.attackboxes.append(self)
  if ray2d:
    ray2d.add_exception(entity)

func check_attack(hitbox):
  if ray2d && hitbox.entity:
    ray2d.add_exception(hitbox.entity)
    ray2d.collision_mask = collision_mask
    ray2d.cast_to = hitbox.entity.global_position - entity.global_position
    ray2d.force_raycast_update()
    var other = ray2d.get_collider()
    ray2d.remove_exception(hitbox.entity)
    if other != null:
      return false
  return true

func handle_hit(hitbox):
  attack_landed(hitbox)
  emit_signal("attack_landed", hitbox)

func attack_landed(hitbox):
  if hitbox.entity:
    hitbox.entity.knockback(entity.global_position.direction_to(hitbox.entity.global_position), knockspeed, knocktime)

func get_power():
  return power

# const LAYER_HEIGHT = 4.0
# const vpos_bits = 1023 #0b1111111111
# const env_bits = 1047552 #0b11111111110000000000

# func shift_layer(vpos):
#   var tier = int(floor(vpos / LAYER_HEIGHT))
#   var parts = base_layer & vpos_bits
#   var mask = base_layer & ~parts
#   parts = parts << tier
#   collision_layer = mask | (parts & vpos_bits)

#   parts = base_layer & env_bits
#   mask = base_layer & ~parts
#   parts = parts << tier
#   collision_layer = mask | (parts & env_bits)

#   parts = base_mask & vpos_bits
#   mask = base_mask & ~parts
#   parts = parts << tier
#   collision_mask = mask | (parts & vpos_bits)

#   parts = base_mask & env_bits
#   mask = base_mask & ~parts
#   parts = parts << tier
#   collision_mask = mask | (parts & env_bits)

# func compute_attack_power():
  # return power
