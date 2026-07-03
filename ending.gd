extends Node

func _ready():
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.z_index = 100
	add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 0), 2.0)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z:
			go_to_main_menu()

func go_to_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
