extends Camera2D

# Pengaturan zoom
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0
@export var max_zoom: float = 3.0
@export var move_speed: float = 500.0

func _input(event: InputEvent) -> void:
	# Cek apakah event adalah tombol mouse
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_camera(zoom_speed) # Zoom In
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_camera(-zoom_speed)  # Zoom Out

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()
	var actual_speed = move_speed / zoom.x
	global_position += input_dir * actual_speed * delta

func _zoom_camera(delta: float):
	# Tambahkan nilai delta ke zoom saat ini
	var new_zoom = zoom.x + delta
	# Batasi agar zoom tidak terlalu jauh atau terlalu dekat
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	# Set nilai zoom baru (x dan y harus sama agar proporsional)
	zoom = Vector2(new_zoom, new_zoom)
