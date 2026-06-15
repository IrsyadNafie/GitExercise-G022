extends Area2D

func _ready():
	if GameManager.collected_coins.has(name):
		queue_free()
		return
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.collected_coins.append(name)
		GameManager.coins += 1
		queue_free()
