extends Node2D

signal task_completed(agent_node) # Untuk memberi tahu UI jika ingin update status

var speed = 50.0
var current_stock = 0
var current_ore
var max_stock = 10
var sprite: Sprite2D
var path_follow: PathFollow2D
var curve_node: Path2D
var label: Label

var from_building: Node2D
var to_building: Node2D
var is_returning = false

func _ready():
	curve_node = $Path2D
	path_follow = $Path2D/PathFollow2D
	sprite = $Path2D/PathFollow2D/Sprite2D
	label = $Path2D/PathFollow2D/Label

func start_mission(start_node, target_node):
	from_building = start_node
	to_building = target_node
	label.text = name
	
	# Ambil rute dari AStar (Ini biasanya Array of Vector2 Global)
	var route = Global.get_route(from_building.global_position, to_building.global_position)
	
	if route.size() > 1:
		var new_curve = Curve2D.new()
		for p in route:
			# PENTING: AStar memberikan Global, Curve2D butuh Local
			new_curve.add_point(to_local(p))
		
		$Path2D.curve = new_curve
		$Path2D/PathFollow2D.progress = 0

func _calculate_route(start_pos, end_pos):
	var route = Global.get_route(start_pos, end_pos) # Fungsi helper di GlobalAStar
	if route.size() > 1:
		var new_curve = Curve2D.new()
		for p in route:
			new_curve.add_point(to_local(p))
		curve_node.curve = new_curve
		path_follow.progress = 0
		path_follow.rotates = true
		set_process(true)
	else:
		print("Rute tidak ditemukan!")

func _process(delta):
	path_follow.progress += speed * delta
	
	if path_follow.progress_ratio >= 0.99:
		set_process(false)
		_on_reached_destination()

func _on_reached_destination():
	var current_building = to_building if not is_returning else from_building
	var target_building = from_building if not is_returning else to_building
	
	# Ambil tipe ore, gunakan "default" jika null
	var ore_type = current_ore if current_ore else "default"

	# 1. Ambil Barang (Supply) dari gedung tempat agent berada sekarang
	if current_building.has_method("_supply_item"):
		var space_available = max_stock - current_stock
		if space_available > 0:
			var amount_taken = current_building._supply_item(space_available, ore_type)
			current_stock += amount_taken
	
	# 2. Taruh Barang (Drop) ke gedung tempat agent berada sekarang
	if current_building.has_method("_drop_item") and current_stock > 0:
		# Update current_stock berdasarkan sisa yang tidak bisa masuk ke gedung
		current_stock = current_building._drop_item(current_stock, ore_type)
		current_ore = current_building.current_ore

	# 3. Toggle Status & Hitung Rute Balik
	is_returning = !is_returning
	var next_target_pos = to_building.global_position if not is_returning else from_building.global_position
	var from_target_pos = to_building.global_position if is_returning else from_building.global_position
	_calculate_route(from_target_pos, next_target_pos)
