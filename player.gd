extends CharacterBody2D

@onready var equipped_item = $EquippedItem
@onready var camera = $Camera2D

# PLAYER STATES
var stunned = false


# MOVEMENT

var speed = 200
var jump_force = -400
var gravity = 900


# HEALTH

var health = 100


# FALL DAMAGE

var max_fall_speed = 0


func _ready():
	

	$Camera2D.make_current()

	# Starting checkpoint
	if GameManager.checkpoint_position == Vector2.ZERO:
		GameManager.checkpoint_position = global_position
	

#Save/Load Game
func _process(delta):

	if Input.is_action_just_pressed("save_game"):
		SaveManager.save_game(1)

	if Input.is_action_just_pressed("load_game"):
		SaveManager.load_game(1)

# EQUIPPED ITEM VISUAL

func update_equipped_item(item_name):

	if item_name == "Key":
		equipped_item.texture = preload("res://yellowkeygodot.png")

	elif item_name == "Potion":
		equipped_item.texture = preload("res://potiongodot.png")

	elif item_name == "Axe":
		equipped_item.texture = preload("res://axegodot.png")

	else:
		equipped_item.texture = null



# MAIN PHYSICS

func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Track strongest fall
	if velocity.y > max_fall_speed:
		max_fall_speed = velocity.y

	
	# MOVEMENT
	
	if not stunned:

		var direction = 0

		if Input.is_action_pressed("ui_right"):
			direction = 1

		if Input.is_action_pressed("ui_left"):
			direction = -1

		velocity.x = direction * speed

	else:
		velocity.x = 0


	# JUMP

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not stunned:
		velocity.y = jump_force

	move_and_slide()

	
	# FALL DAMAGE CHECK
	
	if is_on_floor():

		if max_fall_speed > 700:
			take_fall_damage()

		max_fall_speed = 0



# FALL DAMAGE

func take_fall_damage():

	var damage = int((max_fall_speed - 700) / 20)

	health -= damage

	print("Fall Damage:", damage)
	print("HP Left:", health)

	# Heavy landing effects
	if max_fall_speed > 1000:

		print("HEAVY IMPACT!")

		screen_shake()

		stun_player()

	# Death
	if health <= 0:

		print("Player Died")

		die()



# SCREEN SHAKE

func screen_shake():

	var original_offset = camera.offset

	for i in range(10):

		camera.offset = Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)

		await get_tree().create_timer(0.03).timeout

	camera.offset = original_offset



# TEMP STUN

func stun_player():

	stunned = true

	print("Player Stunned!")

	await get_tree().create_timer(0.5).timeout

	stunned = false

	print("Recovered!")



# DEATH / RESPAWN

func die():

	print("Player died")

	var ui = get_tree().current_scene.get_node("UI")

	await ui.fade_out()

	# Respawn at checkpoint
	if GameManager.checkpoint_position != Vector2.ZERO:
		global_position = GameManager.checkpoint_position

	# Reset HP after death
	health = 100

	await get_tree().create_timer(0.2).timeout

	await ui.fade_in()
	
#Ending Scene
func level_complete(next_scene):
	print("Level Complete!")

	stunned = true
	velocity = Vector2.ZERO

	var ui = get_tree().current_scene.get_node("UI")

	ui.show_interaction("Level Complete!")

	await focus_camera_on_target(global_position + Vector2(250, 0))

	await get_tree().create_timer(1.0).timeout

	await ui.fade_out()

	get_tree().change_scene_to_file(next_scene)
	

#Ending Scene Camera
func focus_camera_on_target(target_position):
	var original_position = camera.global_position

	var tween = create_tween()
	tween.tween_property(camera, "global_position", target_position, 1.0)
	await tween.finished

	await get_tree().create_timer(0.7).timeout

	var tween_back = create_tween()
	tween_back.tween_property(camera, "global_position", original_position, 1.0)
	await tween_back.finished
	
