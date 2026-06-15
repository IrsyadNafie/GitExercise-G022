extends CharacterBody2D

@onready var equipped_item = $EquippedItem

# Movement speed
var speed = 200

# Jump strength
var jump_force = -400

# Gravity strength
var gravity = 900

# Player Health
var health = 100

# Fall speed
var max_fall_speed = 0

func _ready():
	$Camera2D.make_current()
	
	if GameManager.last_player_position != Vector2.ZERO:
		global_position = GameManager.last_player_position + Vector2(0, -10)
		GameManager.last_player_position = Vector2.ZERO 
		
		if GameManager.just_fled:
			modulate = Color(1, 1, 1, 0.5) 
			
			await get_tree().create_timer(2.0).timeout 
			
			modulate = Color(1, 1, 1, 1)
			GameManager.just_fled = false
	
	if GameManager.checkpoint_position == Vector2.ZERO:
		GameManager.checkpoint_position = global_position
	
#For Inventory (Need update for every new items
func update_equipped_item(item_name):

	if item_name == "Key":
		equipped_item.texture = preload("res://yellowkeygodot.png")

	elif item_name == "Potion":
		equipped_item.texture = preload("res://potiongodot.png")
	
	elif item_name == "Axe":
		equipped_item.texture = preload("res://axegodot.png")

	else:
		equipped_item.texture = null

func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Track highest fall speed
	if velocity.y > max_fall_speed:
		max_fall_speed = velocity.y

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
	
	# Player landed
	if is_on_floor():
		# Check if fall was dangerous
		if max_fall_speed > 700:
			take_fall_damage()
			
		# Reset tracking
		max_fall_speed = 0

func take_fall_damage():

	var damage = int((max_fall_speed - 700) / 20)

	health -= damage

	print("Fall Damage:", damage)
	print("HP Left:", health)

	# Optional death
	if health <= 0:
		print("Player Died")
		die()
	
	
func die():
	print("Player died")

	var ui = get_tree().current_scene.get_node("UI")

	await ui.fade_out()

	# teleport to checkpoint
	if GameManager.checkpoint_position != Vector2.ZERO:
		global_position = GameManager.checkpoint_position

	await get_tree().create_timer(0.2).timeout

	await ui.fade_in()
		
#Debug (Death)
#func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):  # Enter key
		#die()
