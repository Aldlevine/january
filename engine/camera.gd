extends Camera2D

export(Vector2) var drag_margin := Vector2(0.2, 0.1)

onready var player = weakref(get_tree().get_root().find_node("player", true, false))

var drag_rect = Rect2()

func _ready():
  var vp_rect = get_tree().get_root().get_viewport().get_visible_rect()
  drag_rect.size = vp_rect.size * drag_margin

func _process(_delta):
  if player.get_ref():
    drag_rect.position = global_position - drag_rect.size / 2
    var player_pos = player.get_ref().global_position
    if !drag_rect.has_point(Vector2(player_pos.x, global_position.y)):
      var xdir = sign(global_position.x - player_pos.x)
      global_position.x = player_pos.x + drag_rect.size.x / 2 * xdir

    if !drag_rect.has_point(Vector2(global_position.x, player_pos.y)):
      var ydir = sign(global_position.y - player_pos.y)
      global_position.y = player_pos.y + drag_rect.size.y / 2 * ydir
      # if player_pos.x > global_position.x:
      #   global_position.x = player_pos.x - drag_rect.size.x / 2
      # elif player_pos.x < global_position.x:
      #   global_position.x = player_pos.x + drag_rect.size.x / 2
      # global_position = player.get_ref().global_position