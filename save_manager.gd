extends Node

const SAVE_PATH = "user://save_slot_"

func save_game(slot):

	var data = {
		"coins": GameManager.coins,
		"inventory": GameManager.inventory,
		"checkpoint": GameManager.checkpoint_position
	}

	var file = FileAccess.open(
		SAVE_PATH + str(slot) + ".save",
		FileAccess.WRITE
	)

	file.store_var(data)

	print("Game Saved Slot", slot)


func load_game(slot):

	var path = SAVE_PATH + str(slot) + ".save"

	if not FileAccess.file_exists(path):
		print("No Save Found")
		return false

	var file = FileAccess.open(path, FileAccess.READ)

	var data = file.get_var()

	GameManager.coins = data["coins"]
	GameManager.inventory = data["inventory"]
	GameManager.checkpoint_position = data["checkpoint"]

	print("Game Loaded Slot", slot)

	return true
