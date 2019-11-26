extends Pickup

func handle_pickup(entity):
  if entity is Player:
    if entity.pain_meds < 30.0:
      entity.pain_meds = 30.0
    queue_free()