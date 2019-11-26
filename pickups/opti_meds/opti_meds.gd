extends Pickup

func handle_pickup(entity):
  if entity is Player:
    if entity.opti_meds < 30.0:
      entity.opti_meds = 30.0
    queue_free()