extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
	

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://start.tscn")


func _on_setting_pressed() -> void:
	get_tree().change_scene_to_file("res://setting.tscn")
	


func _on_exit_pressed() -> void:
	get_tree().quit()
