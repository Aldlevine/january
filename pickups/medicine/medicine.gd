extends Pickup

func handle_pickup(entity):
  entity.health += 1
  queue_free()
