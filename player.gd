extends CharacterBody2D

# Player speed
var speed = 200


func _physics_process(delta):

	var direction = Vector2.ZERO

	# Move left & right
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1

	# Move up & down
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction * speed
	move_and_slide()
