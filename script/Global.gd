extends Node

var mode: String = "default"
var astar = AStar2D.new()
var pos_to_astar = {} # Save Position as Key
var building_to_astar_point = {}
var coors_to_building = {}
var money: float = 2000
var extractor_price: int = 500
var factory_price: int = 500
var coal_price: int = 5 # 5 per 1 coal
var iron_price: int = 10 # 10 per 1 iron
var copper_price: int = 12 # 12 per 1 copper

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_road_to_astar(road: Line2D, name: String):
	var id_start = (name + "_start").hash()
	var id_end = (name + "_end").hash()
	
	var pos_start = road.to_global(road.get_point_position(0))
	var pos_end = road.to_global(road.get_point_position(road.get_point_count() - 1))
	
	if pos_to_astar.has(pos_start):
		id_start = pos_to_astar[pos_start]
	else:
		astar.add_point(id_start, pos_start)
		pos_to_astar[pos_start] = id_start
	
	if pos_to_astar.has(pos_end):
		id_end = pos_to_astar[pos_end]
	else:
		astar.add_point(id_end, pos_end)
		pos_to_astar[pos_end] = id_end

	# Hubungkan internal jalan itu sendiri (selalu ada karena baru dibuat di baris atas)
	astar.connect_points(id_start, id_end)
	
	return id_start

func _add_croad_to_astar(road: Line2D, name: String):
	# Simpan ID titik sebelumnya untuk dihubungkan dengan titik sekarang
	var last_id = -1 
	
	for i in range(road.get_point_count()):
		var pos = road.to_global(road.get_point_position(i))
		var current_id = (name + str(i)).hash()
		
		# 1. Cek apakah titik sudah ada di posisi ini (untuk persimpangan)
		if pos_to_astar.has(pos):
			current_id = pos_to_astar[pos]
		else:
			astar.add_point(current_id, pos)
			pos_to_astar[pos] = current_id
		
		# 2. HUBUNGKAN dengan titik sebelumnya (Kabel antar tiang)
		if last_id != -1:
			# Connect dua arah (bidirectional) agar mobil bisa bolak-balik
			astar.connect_points(last_id, current_id)
			
		# Simpan ID saat ini untuk loop berikutnya
		last_id = current_id

func get_route(from_pos: Vector2, to_pos: Vector2) -> PackedVector2Array:
	var start_id = astar.get_closest_point(from_pos)
	var end_id = astar.get_closest_point(to_pos)
	return astar.get_point_path(start_id, end_id)
