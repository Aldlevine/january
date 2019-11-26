extends TileMap

onready var half_size = cell_size / 2

func _ready():
  for cell in get_used_cells():
    var world_pos = map_to_world(cell) + half_size;
    var id = get_cellv(cell);
    var autotile_coord = get_cell_autotile_coord(cell.x, cell.y);
    var texture = tile_set.tile_get_texture(id);
    var material = tile_set.tile_get_material(id).duplicate();
    var region = tile_set.tile_get_region(id);
    var subtile_size = tile_set.autotile_get_size(id);
    var sprite := Sprite.new();
    sprite.texture = texture;
    sprite.region_enabled = true;
    sprite.region_rect = Rect2(autotile_coord * subtile_size, subtile_size);
    sprite.material = material;
    sprite.global_position = world_pos;
    if is_cell_x_flipped(cell.x, cell.y):
      sprite.flip_h = true
    if is_cell_y_flipped(cell.x, cell.y):
      sprite.flip_v = true
    if is_cell_transposed(cell.x, cell.y):
      sprite.flip_h = false
      sprite.flip_v = false
      sprite.rotate(PI)
    material.set_shader_param("tile_offset", cell)
    get_parent().call_deferred("add_child", sprite)
    get_parent().call_deferred("move_child", sprite, get_index())
  queue_free()


