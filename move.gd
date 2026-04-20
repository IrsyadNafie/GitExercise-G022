extends VBoxContainer

@export var selection_arrow: Node2D
@export var arrow_offset_x: float = 20

func _ready():
	for btn in get_children():
		if btn is Button:
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.focus_mode = Control.FOCUS_ALL
			
			btn.focus_entered.connect(_on_button_focus_entered.bind(btn))

	if get_child_count() > 0:
		var first_btn = get_child(0)
		first_btn.grab_focus()
		_on_button_focus_entered(first_btn)

func _input(event):
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
		
		if btn.alignment == HORIZONTAL_ALIGNMENT_CENTER:
			extra_space = (btn.size.x - min_size.x) / 2.0
		elif btn.alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			extra_space = btn.size.x - min_size.x
		
		var target_x = btn.global_position.x + text_end_x + extra_space + arrow_offset_x
		var target_y = btn.global_position.y + (btn.size.y / 2.0)
		
		selection_arrow.global_position = Vector2(target_x, target_y)

func _execute_selection(btn_name: String):
	match btn_name:
		"attack":
			print("swing")
		"rest":
			print("rest sp")
		"special":
			print("sp")
		"item":
			print("items")
		"flee":
			print("flee")
