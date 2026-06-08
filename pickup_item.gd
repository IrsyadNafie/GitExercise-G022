extends Area2D

@export var item_name = "Potion"
@export var item_id = ""

var player_near = false

func _ready():
	if item_id != "" and item_id in GameManager.picked_items:
		queue_free()
		return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		var ui = get_tree().current_scene.get_node("UI")

		var success = ui.add_item(item_name)

		if success:
			if item_id != "" and not item_id in GameManager.picked_items:
				GameManager.picked_items.append(item_id)

			ui.hide_interaction()
			queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		player_near = true

		var ui = get_tree().current_scene.get_node("UI")
		ui.show_interaction("[E] Pick Up " + item_name)


func _on_body_exited(body):
	if body.name == "Player":
		player_near = false

		var ui = get_tree().current_scene.get_node("UI")
		ui.hide_interaction()
