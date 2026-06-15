extends Area2D

@export var next_scene = "res://room_2.tscn"
@export var exit_door: Node2D

var activated = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not activated:
		if exit_door == null:
			print("ERROR: Exit Door not assigned!")
			return

		activated = true

		body.level_clear_walk_to_door(
			exit_door.global_position,
			next_scene
		)
