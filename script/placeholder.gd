extends Sprite2D

signal place_extractor(coors, current_ore)
signal place_factory(coors)
signal place_road(coors, coors2)
signal place_croad(coors, coors2, coors3)

@export var extractor: Texture2D
@export var road: Texture2D
@export var factory: Texture2D

var pos: Vector2i
var placeable: bool = false
var produceable: bool = false
var current_ore: String
var current_mode: String = "default"
var is_placing_road: bool = false
var first_placing: bool = false
var second_placing: bool = false
var start_point: Vector2i
var control_point: Vector2i
var preview_road: Line2D # Untuk visualisasi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if placeable and Global.mode == "build":
				if current_mode == "extractor" and produceable:
					if Global.money >= Global.extractor_price:
						Global.money -= Global.extractor_price
						place_extractor.emit(pos, current_ore)
				elif current_mode == "factory":
					if Global.money >= Global.factory_price:
						Global.money -= Global.factory_price
						place_factory.emit(pos)
				elif current_mode == "road":
					handle_road_placement()
				elif current_mode == "croad":
					handle_croad_placement()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pos:
		global_position = pos
		centered = false
	
	if is_placing_road and preview_road:
		if current_mode == "road":
			# Update titik kedua preview agar mengikuti mouse
			preview_road.set_point_position(1, pos + Vector2i(8,8))
		
			# Opsional: Berikan warna merah jika area tidak bisa dibangun (not placeable)
			if not placeable:
				preview_road.default_color = Color(1, 0, 0, 0.5)
			else:
				preview_road.default_color = Color(1, 1, 1, 0.5)
		elif current_mode == "croad":
			var temp_curve = Curve2D.new()
			
			if not second_placing:
				# Visualisasi garis lurus biasa (Klik 1 ke Mouse)
				preview_road.set_point_position(1, pos + Vector2i(8,8))
			else:
				# Visualisasi melengkung (Klik 1 -> Klik 2 -> Mouse)
				temp_curve.add_point(start_point)
				# Tambahkan titik kontrol di tengah untuk membuat lengkungan (Quadratic Bezier)
				temp_curve.add_point(pos + Vector2i(8,8), (control_point - (pos + Vector2i(8,8))), Vector2i.ZERO)
				
				# Ambil hasil kalkulasi titik halus dari curve untuk Line2D
				temp_curve.bake_interval = 16.0
				preview_road.points = temp_curve.get_baked_points()

func handle_road_placement() -> void:
	if not is_placing_road:
		# KLIK PERTAMA: Tentukan titik awal
		start_point = pos + Vector2i(8,8) # 'pos' adalah posisi mouse yang sudah disnap ke grid
		is_placing_road = true
		
		# Buat Line2D sementara untuk preview
		preview_road = Line2D.new()
		preview_road.width = 10.0 # Sesuaikan lebar jalan
		preview_road.default_color = Color(1, 1, 1, 0.5) # Putih transparan
		preview_road.add_point(start_point)
		preview_road.add_point(start_point) # Titik kedua akan diupdate di _process
		get_tree().root.add_child(preview_road)
	else:
		# KLIK KEDUA: Finalisasi jalan
		place_road.emit(start_point, pos + Vector2i(8,8)) # Kirim titik awal dan akhir
		finish_road_placement()

func handle_croad_placement() -> void:
	var current_pos = pos + Vector2i(8,8)
	
	if not first_placing:
		# KLIK 1: Tentukan Awal
		start_point = current_pos
		first_placing = true
		is_placing_road = true
		
		preview_road = Line2D.new()
		preview_road.width = 10.0
		preview_road.default_color = Color(1, 1, 1, 0.5)
		preview_road.add_point(current_pos)
		preview_road.add_point(current_pos)
		preview_road.joint_mode = Line2D.LINE_JOINT_ROUND # Agar siku lengkungan halus
		get_tree().root.add_child(preview_road)
		
	elif not second_placing:
		# KLIK 2: Tentukan Titik Kontrol (Tikungan)
		control_point = current_pos
		second_placing = true
		
	else:
		# KLIK 3: Finalisasi (Titik Akhir)
		place_croad.emit(start_point, control_point, current_pos)
		finish_road_placement()

func finish_road_placement() -> void:
	first_placing = false
	second_placing = false
	is_placing_road = false
	if preview_road:
		preview_road.queue_free() # Hapus preview

func set_placeholder(mode_name: String):
	current_mode = mode_name
	if mode_name == "extractor":
		texture = extractor
		z_index = 100
		visible = false
	
	if mode_name == "factory":
		texture = factory
		z_index = 100
		visible = false
	
	if mode_name == "road":
		texture = road
		z_index = 100
		visible = false
	
	if mode_name == "croad":
		texture = road
		z_index = 100
		visible = false

func _on_tile_map_layer_tile_hovered(coords: Variant, is_interactive: Variant, produce: Variant, is_occupied: Variant, is_coal: Variant, is_iron: Variant, is_copper: Variant) -> void:
	if is_coal:
		current_ore = "coal"
	elif is_iron:
		current_ore = "iron"
	elif is_copper:
		current_ore = "copper"
	else:
		current_ore = ""
	
	# Pastikan posisi preview mengikuti grid
	pos = coords * 16
	
	
	if Global.mode == "build":
		visible = true
		
		match current_mode:
			"extractor":
				if produce and (not Global.coors_to_building.has(pos)): # Sesuaikan dengan nilai 'kosong' di data kamu
					self_modulate = Color(1, 1, 1, 0.7)
					placeable = true
					produceable = true
				else:
					self_modulate = Color(1, 0, 0, 0.7) # Merah: Tidak ada sumber daya
					placeable = false
					produceable = false
					
			"factory":
				# Cek apakah tile sudah ditempati bangunan lain (Opsional tapi disarankan)
				if Global.coors_to_building.has(pos):
					self_modulate = Color(1, 0, 0, 0.7)
					placeable = false
				else:
					self_modulate = Color(1, 1, 1, 0.7)
					placeable = true
			
			"road", "croad":
				if is_interactive:
					self_modulate = Color(1, 1, 1, 0.7)
					placeable = true
				else:
					self_modulate = Color(1, 0, 0, 0.7)
					placeable = false
	else:
		visible = false
