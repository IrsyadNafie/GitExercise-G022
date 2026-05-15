extends VBoxContainer

<<<<<<< HEAD
=======
signal action_selected(action_name: String)

>>>>>>> 8acd2005fa674197f3fac22133938a4dfbeee215
@export var selection_arrow: Node2D
@export var arrow_offset_x: float = 20

func _ready():
	for btn in get_children():
		if btn is Button:
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.focus_mode = Control.FOCUS_ALL
<<<<<<< HEAD
			btn.focus_entered.connect(_on_button_focus_entered.bind(btn))
=======
			btn.focus_entered.connect(func(): _on_button_focus_entered(btn))
>>>>>>> 8acd2005fa674197f3fac22133938a4dfbeee215

	if get_child_count() > 0:
		var first_btn = get_child(0)
		first_btn.grab_focus()
		_on_button_focus_entered.call_deferred(first_btn)

func _input(event):
	if not is_visible_in_tree():
		return
		
	if event is InputEventKey:
		if event.physical_keycode == KEY_Z and event.pressed and not event.is_echo():
			var focused_node = get_viewport().gui_get_focus_owner()
			
			if focused_node is Button and is_ancestor_of(focused_node):
				_execute_selection(focused_node.name)

func _on_button_focus_entered(btn: Button):
	if selection_arrow:
		var min_size = btn.get_combined_minimum_size()
		var style = btn.get_theme_stylebox("normal")
		var right_padding = style.content_margin_right
		var text_end_x = min_size.x - right_padding
		var extra_space = 0.0
<<<<<<< HEAD

		if btn.alignment == HORIZONTAL_ALIGNMENT_CENTER:
			extra_space = (btn.size.x - min_size.x) / 2.0
		elif btn.alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			extra_space = btn.size.x - min_size.x
		
		var target_x = btn.global_position.x + text_end_x + extra_space + arrow_offset_x
		var target_y = btn.global_position.y + (btn.size.y / 2.0)
		
		selection_arrow.global_position = Vector2(target_x, target_y)
=======
		
		if btn.alignment == HORIZONTAL_ALIGNMENT_CENTER:
			extra_space = (btn.size.x - min_size.x) / 2.0
		elif btn.alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			extra_space = btn.size.x - min_size.x
		
		var target_x = btn.global_position.x + text_end_x + extra_space + arrow_offset_x
		var target_y = btn.global_position.y + (btn.size.y / 2.0)
		
		selection_arrow.global_position = Vector2(target_x, target_y)

>>>>>>> 8acd2005fa674197f3fac22133938a4dfbeee215
func _execute_selection(btn_name: String):
	match btn_name:
		"attack":
			print("swing")
			action_selected.emit("attack")
		"rest":
			print("rest sp")
			action_selected.emit("rest")
		"special":
			print("sp")
			action_selected.emit("special")
		"item":
			print("items")
			action_selected.emit("item")
		"flee":
			print("flee")
			action_selected.emit("flee")
