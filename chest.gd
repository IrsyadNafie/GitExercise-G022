extends Area2D

var player_near = false
var opened = false

func _ready():
	# No local label needed anymore
	pass

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact") and not opened:
		open_chest()

func open_chest():
	var ui = get_tree().current_scene.get_node("UI")

	if ui.has_item("Key"):
		ui.remove_item("Key")
		GameManager.coins += 10
		opened = true

		ui.show_interaction("Opened! +10 coins")
		print("Chest opened! +10 coins")

		# Optional: change chest sprite after opening
		# $Sprite2D.texture = preload("res://chest_open.png")

	else:
		ui.show_interaction("Need a key")
		print("Need a key")

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true

		var ui = get_tree().current_scene.get_node("UI")

		if opened:
			ui.show_interaction("Chest already opened")
		else:
			ui.show_interaction("[E] Open Chest")

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false

		var ui = get_tree().current_scene.get_node("UI")
		ui.hide_interaction()
