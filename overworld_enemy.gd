extends CharacterBody2D

@export var enemy_id: String = "map_enemy_1"
@export var battle_scene_path: String = "res://control.tscn"

var speed = 80
var gravity = 900
var direction = 1 
var move_timer = 0.0

func _ready() -> void:
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()

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
	print("Hitbox was touched by: ", body.name)
	if body.name == "Player":
		print("Player detected! Teleporting...")
		GameManager.last_player_position = body.global_position
		GameManager.last_overworld_scene = get_tree().current_scene.scene_file_path
		GameManager.enemy_just_defeated = enemy_id
		
		get_tree().change_scene_to_file(battle_scene_path)
