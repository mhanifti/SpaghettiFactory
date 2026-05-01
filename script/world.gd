extends Node2D

@onready var custom_cursor = $Camera2D/Cursor
@onready var placeholder = $Camera2D/Placeholder
@onready var camera = $Camera2D
@onready var canvas = $Camera2D/CanvasLayer
@onready var mode = Global.mode

@export var extractor_scene: PackedScene
@export var factory_scene: PackedScene
@export var road_scene: PackedScene
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0
@export var max_zoom: float = 3.0

var buildings: Array[Node2D] = []
var roads: Array[Line2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var mouse_pos: Vector2 = event.position
		
	if (event.is_action_pressed("cancel")):
		Global.mode = "default"
		custom_cursor.set_cursor_mode("normal")

func _on_straight_pressed() -> void:
	custom_cursor.set_cursor_mode("default")
	placeholder.set_placeholder("road")
	Global.mode = "build"

func _on_placeholder_place_road(coors: Variant, coors2: Variant) -> void:
	var road = road_scene.instantiate()
	road.add_point(coors)
	road.add_point(coors2)
	add_child(road)
	roads.append(road)
	road.name = "road" + str(roads.size())
	Global._add_road_to_astar(road, road.name)

func _on_curve_pressed() -> void:
	custom_cursor.set_cursor_mode("default")
	placeholder.set_placeholder("croad")
	Global.mode = "build"

func _on_placeholder_place_croad(coors: Variant, coors2: Variant, coors3: Variant) -> void:
	var road = road_scene.instantiate()
	roads.append(road)
	road.name = "road" + str(roads.size())
	
	var c = Curve2D.new()
	c.add_point(coors)
	# Menggunakan p_control sebagai 'in control' untuk titik akhir
	c.add_point(coors3, Vector2i(coors2) - coors3, Vector2.ZERO)
	c.bake_interval = 16.0
	
	road.points = c.get_baked_points()
	add_child(road)
	
	Global._add_croad_to_astar(road, road.name)

func _on_extractor_pressed() -> void:
	custom_cursor.set_cursor_mode("default")
	placeholder.set_placeholder("extractor")
	Global.mode = "build"

func _on_placeholder_place_extractor(coors: Variant, current_ore: Variant) -> void:
	var building: Node2D = extractor_scene.instantiate()
	if building.has_method("set_ore"):
		building.set_ore(current_ore)
	building.position = coors
	building.z_index = 2
	add_child(building)
	buildings.append(building)
	building.name = "building" + str(buildings.size())
	var id_p = Global._add_road_to_astar(building.find_child("Line2D"), building.name)
	Global.building_to_astar_point[building] = id_p
	canvas.refresh_dropdowns()

func _on_factory_pressed() -> void:
	custom_cursor.set_cursor_mode("default")
	placeholder.set_placeholder("factory")
	Global.mode = "build"

func _on_placeholder_place_factory(coors: Variant) -> void:
	var building: Node2D = factory_scene.instantiate()
	building.position = coors
	building.z_index = 2
	add_child(building)
	buildings.append(building)
	building.name = "building" + str(buildings.size())
	var id_p = Global._add_road_to_astar(building.find_child("Line2D"), building.name)
	Global.building_to_astar_point[building] = id_p
	canvas.refresh_dropdowns()

func _on_exit_and_save_pressed():
	get_tree().change_scene_to_file("res://scenes/MainPage.tscn")
