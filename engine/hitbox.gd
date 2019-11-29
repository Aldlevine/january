extends Area2D

class_name Hitbox


export var air := false
onready var entity := get_parent()
onready var base_layer = collision_layer
onready var base_mask = collision_mask

func _ready():
  entity.hitboxes.append(self)