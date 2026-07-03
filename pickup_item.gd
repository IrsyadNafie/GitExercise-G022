extends Area2D

@export var item_name = "Key"
@export var item_id = ""

var player_near = false
@onready var prompt_label = $Label # Make sure your Label node is exactly named "Label"

func _ready():
	if item_id != "" and item_id in GameManager.picked_items:
		queue_free()
		return
		
	if prompt_label:
		prompt_label.hide()
		prompt_label.text = "[E] Pick Up " + item_name

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		
		# Safely force the item into the inventory without a UI
		var empty_slot = GameManager.inventory.find("")
		if empty_slot != -1:
			GameManager.inventory[empty_slot] = item_name
		else:
			GameManager.inventory.append(item_name)
			
		if item_id != "" and not item_id in GameManager.picked_items:
			GameManager.picked_items.append(item_id)
			
		queue_free()

func _on_body_entered(body):
	if body.name == "player" or body.name == "Player":
		player_near = true
		if prompt_label:
			prompt_label.show()

func _on_body_exited(body):
	if body.name == "player" or body.name == "Player":
		player_near = false
		if prompt_label:
			prompt_label.hide()
