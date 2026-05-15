extends Control

@onready var hp_bar = $PlayerPanel/HPBar
@onready var sp_bar = $PlayerPanel/SPBar
@onready var exp_bar = $PlayerPanel/EXP

func update_hp(current_hp, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func update_sp(current_sp, max_sp):
	sp_bar.max_value = max_sp
	sp_bar.value = current_sp

func update_xp(current_xp, max_xp):
	exp_bar.max_value = max_xp
	if current_xp >= max_xp:
		exp_bar.value = current_xp - max_xp
<<<<<<< HEAD
=======
		print("xp reached go back to ", exp_bar.value)
>>>>>>> 8acd2005fa674197f3fac22133938a4dfbeee215
	else:
		exp_bar.value = current_xp

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.physical_keycode == KEY_W:
			update_hp(hp_bar.value - 1, hp_bar.max_value)

		elif event.physical_keycode == KEY_S:
			update_sp(sp_bar.value - 1, sp_bar.max_value)

		elif event.physical_keycode == KEY_A:
			update_xp(exp_bar.value + 1, exp_bar.max_value)
