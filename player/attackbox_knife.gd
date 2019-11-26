extends Attackbox

func get_power():
  var strength = entity.get("strength") if entity.get("strength") != null else 1.0
  return power * strength