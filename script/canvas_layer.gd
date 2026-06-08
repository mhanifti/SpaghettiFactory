extends CanvasLayer

@onready var from_opt: OptionButton = $MarginContainer/VBoxContainer/HBoxTopContainer/HBoxContainer/FromOption
@onready var to_opt: OptionButton = $MarginContainer/VBoxContainer/HBoxTopContainer/HBoxContainer/ToOption
@onready var agent_list_ui = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer # Tempat tombol delete muncul
@onready var money_label: Label = $MarginContainer/VBoxContainer/HBoxTopContainer/Money

@export var agent_scene: PackedScene

var name_to_building = {}
var active_agents = {} # {agent_instance: ui_button}
var car_count = 1

func _ready():
	pass

func _process(delta: float) -> void:
	money_label.text = "Money = " + str(floor(Global.money))

func refresh_dropdowns():
	from_opt.clear()
	to_opt.clear()
	if Global.building_to_astar_point.keys().size() > 0:
		for b_name in Global.building_to_astar_point.keys():
			name_to_building[b_name.name] = b_name
			from_opt.add_item(b_name.name)
			to_opt.add_item(b_name.name)

func _on_spawn_button_pressed():
	var start_txt = from_opt.get_item_text(from_opt.selected)
	var target_txt = to_opt.get_item_text(to_opt.selected)
	if start_txt and target_txt:
		var start_b = name_to_building[start_txt]
		var target_b = name_to_building[target_txt]
		
		if start_b and target_b:
			var new_agent = agent_scene.instantiate()
			
			# JANGAN add_child(new_agent) ke CanvasLayer
			# Tambahkan ke root scene atau node khusus YSort/World
			get_tree().current_scene.add_child(new_agent) 
			
			# Set posisi awal agent ke posisi gedung
			new_agent.global_position = start_b.global_position
			
			# Set Name
			new_agent.name = "Car_" + str(car_count)
			car_count += 1
			
			# Mulai misi
			new_agent.start_mission(start_b, target_b)
			
			_add_to_ui_list(new_agent)
	else:
		pass

func _add_to_ui_list(agent):
	var btn = Button.new()
	btn.text = "Delete " + str(agent.name)
	btn.pressed.connect(func(): _delete_agent(agent, btn))
	agent_list_ui.add_child(btn)
	active_agents[agent] = btn

func _delete_agent(agent, btn):
	if is_instance_valid(agent):
		agent.queue_free()
	btn.queue_free()
	active_agents.erase(agent)
