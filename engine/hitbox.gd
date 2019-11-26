extends Area2D

class_name Hitbox


export var air := false
onready var entity := get_parent()

func _ready():
  entity.hitboxes.append(self)