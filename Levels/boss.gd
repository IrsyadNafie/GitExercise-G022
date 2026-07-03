extends Area2D

@export var dialog_scene_path: String = "res://dialog/dialog_ui.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file(dialog_scene_path)
