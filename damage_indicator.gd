extends Marker2D

var damage_amount: int = 0
var shake_timer: float = 0.4
var base_label_pos: Vector2

func _ready() -> void:
	var label = get_node_or_null("Label")
	if label:
		label.text = str(damage_amount)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.reset_size()
		label.position = -label.size / 2.0
		base_label_pos = label.position 
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.5)
	
	await fade_tween.finished
	queue_free()

func _process(delta: float) -> void:
	var label = get_node_or_null("Label")
	if label:
		if shake_timer > 0:
			shake_timer -= delta
			label.position = base_label_pos + Vector2(randf_range(-4, 4), randf_range(-4, 4))
		else:
			label.position = base_label_pos
