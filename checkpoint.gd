extends Area2D

@onready var label = $"../UI/CheckpointLabel"  # we’ll make this UI next

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.checkpoint_position = body.global_position
		print("Checkpoint Saved:", GameManager.checkpoint_position)

		show_message()


func show_message():
	label.text = "Checkpoint Reached!"
	await get_tree().create_timer(2.0).timeout
	label.text = ""
