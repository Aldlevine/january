extends Entity

func state_default(delta):
  gravity_loop(delta)
  movement_loop()
  damage_loop()