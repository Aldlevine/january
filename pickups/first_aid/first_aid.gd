extends Pickup

func handle_pickup(entity):
  entity.health += 3
  queue_free()