extends Area2D

var damage = 20

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		body.take_lava_damage(damage)
