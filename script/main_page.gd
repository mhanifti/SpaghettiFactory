extends MarginContainer

@onready var continue_btn = $VBoxContainer/Continue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")


func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit.tscn")

#TODO: Button Continue

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
