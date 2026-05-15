extends Area2D

var player_near = false
var opened = false

func _ready():
	$Label.text = ""

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact") and not opened:
		open_chest()

func open_chest():
	var ui = get_tree().current_scene.get_node("UI")

	# check if player has key
	if ui.has_item("Key"):
		ui.remove_item("Key")   # consume key
		GameManager.coins += 10
		opened = true

		$Label.text = "Opened! +10 coins"
		print("Chest opened")

		# OPTIONAL: change sprite if I plan in future
		# $Sprite2D.texture = preload("res://chest_open.png")

	else:
		$Label.text = "Need a key"
		print("No key")

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true
		$Label.text = "Press E to open"

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$Label.text = ""
