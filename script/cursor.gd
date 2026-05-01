extends Sprite2D

@onready var cam = get_viewport().get_camera_2d()

@export var default_cursor: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if cam:
		var inv_zoom = 1.2/cam.zoom.x
		scale = Vector2(inv_zoom, inv_zoom)

func set_cursor_mode(mode_name: String):
	if mode_name == "normal":
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var variable_to_find = mode_name + "_cursor"
		var new_texture = get(variable_to_find)
		
		if new_texture:
			texture = new_texture
		else:
			print("Error: No variable found named ", variable_to_find)
