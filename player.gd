extends CharacterBody2D

@onready var equipped_item = $EquippedItem
@onready var camera = $Camera2D

@onready var character_body_2d: CharacterBody2D = $"."
@onready var anim = $AnimatedChar/SquareWalk/AnimationPlayer
@onready var sprite = $AnimatedChar/SquareWalk


# PLAYER STATES
var stunned = false

# LEVEL CLEAR
var level_clear_mode = false
var level_clear_target = Vector2.ZERO
var level_clear_next_scene = ""

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
		
	var ui = get_tree().current_scene.get_node("UI")
	ui.update_irsyad_health_bar(health)

	

#Save/Load Game
func _process(delta):

	if Input.is_action_just_pressed("save_game"):
		SaveManager.save_game(1)

	if Input.is_action_just_pressed("load_game"):
		SaveManager.load_game(1)

# EQUIPPED ITEM VISUAL

func update_equipped_item(item_name):
	if equipped_item == null:
		return

	if item_name == "Key":
		equipped_item.texture = preload("res://InteractableObjects/yellowkeygodot.png")

	elif item_name == "Potion":
		equipped_item.texture = preload("res://potiongodot.png")

	elif item_name == "Axe":
		equipped_item.texture = preload("res://InteractableObjects/axegodot.png")

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

	# Auto walk during level clear
	if level_clear_mode:
		handle_level_clear()
		update_animation()
		move_and_slide()
		return
		
	update_animation()
	move_and_slide()

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

#Character Animation -- Cinda
func update_animation():
	if abs(velocity.x) > 5:
		if anim.current_animation != "square_walk":
			anim.play("square_walk")

		if velocity.x > 0:
			sprite.flip_h = true
		elif velocity.x < 0:
			sprite.flip_h = false
	else:
		if anim.current_animation != "idle":
			anim.play("idle")
	
	# FALL DAMAGE CHECK
	
	if is_on_floor():

		if max_fall_speed > 700:
			take_fall_damage()

		max_fall_speed = 0

#Hit by a Lava
func take_lava_damage(damage):
	health -= damage
	
	var ui = get_tree().current_scene.get_node("UI")
	ui.update_irsyad_health_bar(health)

	print("Lava Damage:", damage)
	print("HP Left:", health)

	screen_shake()

	velocity.y = -350

	if health <= 0:
		print("Player died from lava")
		die()

# FALL DAMAGE

func take_fall_damage():

	var damage = int((max_fall_speed - 700) / 20)

	health -= damage
	var ui = get_tree().current_scene.get_node("UI")
	ui.update_irsyad_health_bar(health)

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
	ui.update_irsyad_health_bar(health)

	await get_tree().create_timer(0.2).timeout

	await ui.fade_in()
	
func level_clear_walk_to_door(door_pos, next_scene):

	level_clear_mode = true
	level_clear_target = door_pos
	level_clear_next_scene = next_scene

	stunned = true

	print("Walking to exit...")


func handle_level_clear():
	var distance = level_clear_target.x - global_position.x

	if abs(distance) > 8:
		var direction = sign(distance)
		velocity.x = direction * 120
	else:
		global_position.x = level_clear_target.x
		velocity.x = 0
		level_clear_mode = false
		stage_clear()


func stage_clear():

	var ui = get_tree().current_scene.get_node("UI")

	ui.show_interaction("STAGE CLEAR!")

	# Zoom camera
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(0.6, 0.6), 0.8)

	await tween.finished
	await get_tree().create_timer(1.0).timeout

	await ui.fade_out()

	get_tree().change_scene_to_file(level_clear_next_scene)
