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

func handle_hit(hitbox):
  emit_signal("attack_landed", hitbox)
  attack_landed(hitbox)

func attack_landed(hitbox):
  if hitbox.entity:
    hitbox.entity.knockback(entity.global_position.direction_to(hitbox.entity.global_position), knockspeed, knocktime)

func get_power():
  return power

# func compute_attack_power():
  # return power
