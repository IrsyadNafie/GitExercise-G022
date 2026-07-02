extends CharacterBody2D

@export var enemy_id: String = "map_enemy_1"

@export var dialog_scene_path: String = "res://dialog/dialog_ui.tscn"
@export var actual_battle_scene_path: String = "res://battle/control.tscn" 

@export var skip_dialog_for_testing: bool = true 

var can_start_battle: bool = false
var speed = 80
var gravity = 900
var direction = 1
var move_timer = 0.0

func _ready() -> void:
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()
	await get_tree().create_timer(1.5).timeout
	can_start_battle = true

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_timer -= delta
	if move_timer <= 0:
		direction = [-1, 1].pick_random()
		move_timer = randf_range(1.5, 3.5)
		
	if is_on_wall():
		direction *= -1
		
	velocity.x = direction * speed
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if GameManager.just_fled or not can_start_battle:
		return
		
	if body.name == "Player":
		var camera = body.get_node_or_null("Camera2D")
		if camera:
			camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
			camera.limit_left = -10000000
			camera.limit_right = 10000000
			camera.limit_top = -10000000
			camera.limit_bottom = 10000000
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(camera, "zoom", Vector2(5, 5), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tween.tween_property(camera, "global_position", body.global_position, 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tween.chain() 
			await tween.finished 
			
			GameManager.last_overworld_scene = get_tree().current_scene.scene_file_path
			GameManager.last_player_position = body.global_position
			GameManager.enemy_just_defeated = enemy_id
			
		if skip_dialog_for_testing:
			get_tree().change_scene_to_file(actual_battle_scene_path)
		else:
			get_tree().change_scene_to_file(dialog_scene_path)
