extends Area2D

@export var item_name = "Potion"

var player_near = false

func _ready():
	$Label.text = ""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		var ui = get_tree().current_scene.get_node("UI")
		ui.add_item(item_name)
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true
		$Label.text = "Press E"

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$Label.text = ""

func _on_label_child_entered_tree(node: Node) -> void:
	pass # Replace with function body.


func _on_label_child_exiting_tree(node: Node) -> void:
	pass # Replace with function body.
