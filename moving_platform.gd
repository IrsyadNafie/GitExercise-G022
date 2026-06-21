extends AnimatableBody2D

@export var move_distance = 300
@export var move_speed = 2.0

var start_position
var target_position
var moving_to_target = true

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(move_distance, 0)

func _physics_process(delta):
	var target = target_position

	if not moving_to_target:
		target = start_position

	global_position = global_position.move_toward(target, move_speed * 100 * delta)

	if global_position.distance_to(target) < 2:
		moving_to_target = !moving_to_target
