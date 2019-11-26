extends CanvasLayer

onready var player = weakref(get_tree().get_root().find_node("player", true, false))
onready var health = $Control/health

func _process(_delta):
  var p = player.get_ref();
  if p:
    health.rect_size.x = p.max_health * 8 + 2
    health.max_value = p.max_health
    health.value = p.health

    $Control/rock_counter/label.text = str(p.num_rocks)