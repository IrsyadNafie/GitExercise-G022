extends Node

const SAVE_PATH = "user://save_slot_"

func save_game(slot):
	var player = get_tree().current_scene.get_node("Player")
	var scene_path = get_tree().current_scene.scene_file_path

	var data = {
		"coins": GameManager.coins,
		"inventory": GameManager.inventory,
		"picked_items": GameManager.picked_items,
		"checkpoint_x": GameManager.checkpoint_position.x,
		"checkpoint_y": GameManager.checkpoint_position.y,
		"player_x": player.global_position.x,
		"player_y": player.global_position.y,
		"scene": scene_path
	}

	var file = FileAccess.open(SAVE_PATH + str(slot) + ".save", FileAccess.WRITE)
	file.store_var(data)
	file.close()

	print("Saved scene:", scene_path)
	print("Saved position:", player.global_position)


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
	GameManager.picked_items = data["picked_items"]
	GameManager.checkpoint_position = Vector2(data["checkpoint_x"], data["checkpoint_y"])

	var saved_position = Vector2(data["player_x"], data["player_y"])
	var saved_scene = data["scene"]

	print("Loading scene:", saved_scene)
	print("Loading position:", saved_position)

	get_tree().change_scene_to_file(saved_scene)

	await get_tree().process_frame
	await get_tree().process_frame

	var player = get_tree().current_scene.get_node("Player")
	player.global_position = saved_position

	print("Player moved to:", player.global_position)

	return true
