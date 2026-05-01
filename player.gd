extends CharacterBody2D

# Movement speed
var speed = 200

# Jump strength
var jump_force = -400

# Gravity strength
var gravity = 900

func _ready():
	$Camera2D.make_current()

func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Move left and right
	var direction = 0
	
	if Input.is_action_pressed("ui_right"):
		direction = 1
		
	if Input.is_action_pressed("ui_left"):
		direction = -1

	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
	
