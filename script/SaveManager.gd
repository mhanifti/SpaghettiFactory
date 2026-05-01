extends Node

const SAVE_PATH = "user://savegame.json"

# Data default untuk New Game
var game_data = {
	"player_money": 100,
	"buildings": [], # Menyimpan { "type": "factory", "pos": Vector2(...) }
	"building_to_astar": {},
	"internal_stocks": {} # Menyimpan { "building_id": 50 }
}

func save_to_disk():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(game_data)
	file.store_string(json_string)
	print("Game Saved ke: ", OS.get_user_data_dir())

func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.parse_string(json_string)
	
	if json:
		game_data = json
		return true
	return false
