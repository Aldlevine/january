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

func _ready():
  entity.attackboxes.append(self)

func handle_hit(hitbox):
  emit_signal("attack_landed", hitbox)
  attack_landed(hitbox)

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
