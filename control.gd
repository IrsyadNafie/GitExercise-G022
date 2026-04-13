extends Control

@onready var hp_bar = $HPBar
@onready var sp_bar = $SPBar
func update_hp(current_hp, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func update_sp(current_sp, max_sp):
	sp_bar.max_value = max_sp
	sp_bar.value = current_sp

func _input(event):
	if event.is_action_pressed("ui_up"):
		update_hp(hp_bar.value - 1, hp_bar.max_value)
	
	if event.is_action_pressed("ui_down"):
		update_sp(sp_bar.value - 1, sp_bar.max_value)
