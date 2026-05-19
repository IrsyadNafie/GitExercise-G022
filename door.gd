extends Area2D

var player_near = false

@export var next_scene : String

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(next_scene)

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true
		$PressE.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$PressE.visible = false
