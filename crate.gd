extends CharacterBody2D

var gravity = 500
var landed = false

var stored_items = []  # IMPORTANT

var player_near = false

func _ready():
	$Label.text = ""

func _physics_process(delta):
	if not landed:
		velocity.y += gravity * delta
		move_and_slide()

		if is_on_floor():
			landed = true
			velocity = Vector2.ZERO
			$Label.text = "Press E"


func _process(delta):
	if player_near:
		if Input.is_action_just_pressed("interact"):
			print("E PRESSED")

			if landed:
				print("CRATE OPEN:", stored_items)
			else:
				print("NOT LANDED YET")

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_near = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_near = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
