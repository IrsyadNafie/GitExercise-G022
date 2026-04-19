extends VBoxContainer

@export var selection_arrow: Node2D 
@export var arrow_offset_x: float = -150.0 

func _ready():
	# 1. Setup all buttons
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

		var btn_pos = btn.global_position
		
		var new_pos = Vector2(
			btn_pos.x + arrow_offset_x,
			btn_pos.y + (btn.size.y / 1)
		)
		
		selection_arrow.global_position = new_pos

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
