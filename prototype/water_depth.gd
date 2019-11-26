extends TileMap

export var max_depth := 6.0;

func get_depth_at_point(point):
  var color = get_color_at_point(point)
  return round(color.r * max_depth);

func get_color_at_point(point):
  var cell = world_to_map(point)
  var tile_id = get_cellv(cell)

  if tile_id == -1:
    return Color(0, 0, 0, 0)

  var autotile_coord = get_cell_autotile_coord(cell.x, cell.y)
  var subtile_size = tile_set.autotile_get_size(tile_id)
  var tile_region = tile_set.tile_get_region(tile_id)
  var texture = tile_set.tile_get_texture(tile_id)
  var image = texture.get_data()
  var pos_in_cell = Vector2(fmod(point.x, cell_size.x), fmod(point.y, cell_size.y))
  var pos_in_image = pos_in_cell + tile_region.position + (subtile_size * autotile_coord)
  image.lock()
  var color = image.get_pixelv(pos_in_image)
  image.unlock()
  return color
