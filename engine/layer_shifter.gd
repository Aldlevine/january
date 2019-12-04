extends Node

const LAYER_HEIGHT = 4.0
const base_bits = 1023 #0b1111111111
const env_bits = 1047552 #0b11111111110000000000

func shift_layer(obj, vpos):
  if obj.base_layer == null || obj.base_mask == null:
    return

  var tier = int(floor(vpos / LAYER_HEIGHT))
  var parts = obj.base_layer & base_bits
  parts = parts << tier
  obj.collision_layer = parts & base_bits

  parts = obj.base_layer & env_bits
  parts = parts << tier
  obj.collision_layer |= parts & env_bits

  parts = obj.base_mask & base_bits
  parts = parts << tier
  obj.collision_mask = parts & base_bits

  parts = obj.base_mask & env_bits
  parts = parts << tier
  obj.collision_mask |= parts & env_bits
