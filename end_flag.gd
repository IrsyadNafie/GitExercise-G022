extends Area2D

@export var next_scene = "res://room_2.tscn"

var activated = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not activated:
		activated = true
		body.level_complete(next_scene)
