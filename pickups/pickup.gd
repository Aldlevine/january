extends Node2D

class_name Pickup

signal pickup(entity)

var pickedup := false

func _ready():
  global_position = global_position.round()

func pickup(entity):
  if pickedup: return
  pickedup = true
  handle_pickup(entity)
  emit_signal("pickup", entity)

func handle_pickup(_entity):
  pass