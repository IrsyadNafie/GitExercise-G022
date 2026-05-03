extends Node2D

var turn_queue: Array[Actor] = []
var current_actor_index: int = 0

@onready var ui_layer = $UI
@onready var action_menu = $UI/PlayerPanel/move
@onready var battle_log = $UI/PlayerPanel/BattleLog/RichTextLabel

func _ready() -> void:
	action_menu.hide()
	action_menu.action_selected.connect(_on_ui_action_selected)
	battle_log.text = ""
	var actor_nodes = $Actors.get_children()
	for node in actor_nodes:
		if node is Actor:
			turn_queue.append(node)
			node.turn_finished.connect(_on_actor_turn_finished)
			node.action_logged.connect(_on_actor_logged)

	_on_actor_logged("battle start")
	start_next_turn()

func start_next_turn() -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	
	_on_actor_logged("[color=black]----" + current_actor.character_name + " turn----[/color]")
	
	current_actor.start_turn()
	
	if current_actor.is_player:
		var first_btn = action_menu.get_child(0)
		if first_btn:
			first_btn.text = current_actor.attack_name
		action_menu.show()
		if first_btn:
			first_btn.grab_focus()
	else:
		action_menu.hide()

func _on_ui_action_selected(action: String) -> void:
	action_menu.hide()
	var current_actor: Actor = turn_queue[current_actor_index]
	current_actor.action_logged.emit("[color=white]>" + current_actor.character_name + " uses " + action + "[/color]")
	if action == current_actor.attack_name:
		current_actor.action_logged.emit("[color=white]>dealing 15 damage[/color]")
	elif action == "rest":
		current_actor.action_logged.emit("[color=white]>restoring some hp and sp[/color]")
	current_actor.end_turn()

func _on_actor_turn_finished() -> void:
	current_actor_index += 1
	if current_actor_index >= turn_queue.size():
		current_actor_index = 0
	start_next_turn()

func _on_actor_logged(text: String) -> void:
	if battle_log != null:
		battle_log.append_text(text + "\n")
