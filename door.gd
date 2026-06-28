extends Area2D

@export_file("*.tscn") var next_scene : String

var player_inside = false

func _ready():
	$Label.visible = false


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		$Label.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		$Label.visible = false


func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(next_scene)
