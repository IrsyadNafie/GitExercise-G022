extends Node

const SAVE_PATH = "user://save_slot_"

func save_game(slot):
	var player = get_tree().current_scene.get_node("Player")

	var data = {
		"coins": GameManager.coins,
		"inventory": GameManager.inventory,
		"checkpoint_x": GameManager.checkpoint_position.x,
		"checkpoint_y": GameManager.checkpoint_position.y,
		"player_x": player.global_position.x,
		"player_y": player.global_position.y,
		"scene": get_tree().current_scene.scene_file_path
	}

	var file = FileAccess.open(SAVE_PATH + str(slot) + ".save", FileAccess.WRITE)
	file.store_var(data)
	file.close()

	print("Game Saved Slot ", slot)


func load_game(slot):
	var path = SAVE_PATH + str(slot) + ".save"

	if not FileAccess.file_exists(path):
		print("No Save Found")
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	var data = file.get_var()
	file.close()

	GameManager.coins = data["coins"]
	GameManager.inventory = data["inventory"]
	GameManager.checkpoint_position = Vector2(data["checkpoint_x"], data["checkpoint_y"])

	GameManager.load_player_position = Vector2(data["player_x"], data["player_y"])

	get_tree().change_scene_to_file(data["scene"])

	print("Game Loaded Slot ", slot)
	return true
