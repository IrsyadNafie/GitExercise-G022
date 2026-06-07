extends Area2D

@export var coin_id = ""

func _ready():
	if coin_id != "" and coin_id in GameManager.picked_items:
		queue_free()
		return

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.coins += 1

		if coin_id != "" and not coin_id in GameManager.picked_items:
			GameManager.picked_items.append(coin_id)

		queue_free()
