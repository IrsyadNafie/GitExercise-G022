extends Control 

@onready var hp_bar = $PlayerPanel/HPBar
@onready var sp_bar = $PlayerPanel/SPBar

func update_hp(current_hp, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func update_sp(current_sp, max_sp):
	sp_bar.max_value = max_sp
	sp_bar.value = current_sp

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.physical_keycode == KEY_W:
			update_hp(hp_bar.value - 1, hp_bar.max_value)

		if event.physical_keycode == KEY_S:
			update_sp(sp_bar.value - 1, sp_bar.max_value)
