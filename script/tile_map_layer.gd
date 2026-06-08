extends TileMapLayer

signal tile_hovered(coords, can_produce, is_occupied, is_coal, is_iron, is_copper)

var last_hovered_tile = Vector2i(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var current_tile = local_to_map(mouse_pos)
	
	if current_tile != last_hovered_tile:
		_handle_tile_enter(current_tile)
		last_hovered_tile = current_tile

func _handle_tile_enter(coords: Vector2i):
	var data = get_cell_tile_data(coords)
	if data and data.get_custom_data("is_interactive"):
		tile_hovered.emit(coords, data.get_custom_data("is_interactive"), data.get_custom_data("can_produce"), data.get_custom_data("is_occupied"), data.get_custom_data("is_coal"), data.get_custom_data("is_iron"), data.get_custom_data("is_copper"))

func _handle_tile_occupied(coords):
	var data = get_cell_tile_data(coords)
	data.set_custom_data("is_occupied", true)
