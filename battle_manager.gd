extends Node2D

var turn_queue: Array[Actor] = []
var current_actor_index: int = 0

var active_enemies: Array[Actor] = []
var is_targeting: bool = false
var target_index: int = 0

@onready var menu_arrow = $UI/PlayerPanel/arrow
@onready var ui_layer = $UI
@onready var action_menu = $UI/PlayerPanel/move
@onready var battle_log = $UI/PlayerPanel/BattleLog/RichTextLabel

func _ready() -> void:
	action_menu.hide()
	action_menu.action_selected.connect(_on_ui_action_selected)
	
	if battle_log:
		var scrollbar = battle_log.get_v_scroll_bar()
		if scrollbar: scrollbar.modulate = Color.TRANSPARENT
	var actor_nodes = $Actors.get_children()

	for node in actor_nodes:
		if node is Actor:
			turn_queue.append(node)
			node.turn_finished.connect(_on_actor_turn_finished)
			node.action_logged.connect(_on_actor_logged)
			
			if not node.is_player:
				active_enemies.append(node)
	_on_actor_logged("Battle Start!")
	start_next_turn()

func start_next_turn() -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	_on_actor_logged("[color=red]---- " + current_actor.character_name + " turn ----[/color]")
	current_actor.start_turn()
	if current_actor.is_player:
		var first_btn = action_menu.get_child(0)
		if first_btn:
			first_btn.text = current_actor.attack_name
		
		action_menu.show()
		menu_arrow.show()
		if first_btn:
			first_btn.grab_focus()
	else:
		action_menu.hide()

func _on_ui_action_selected(action: String) -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	print("Menu sent action: ", action)
	print("Expected custom name: ", current_actor.attack_name)
	if action == current_actor.attack_name or action == "attack":
		if current_actor.is_aoe_attack:
			menu_arrow.hide()
			action_menu.hide()
			execute_aoe_attack()
		else:
			get_viewport().gui_release_focus()
			await get_tree().process_frame
			start_targeting()
	elif action == "rest":
		action_menu.hide()
		current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " rests...[/color]")
		finish_action()

func start_targeting() -> void:
	is_targeting = true
	menu_arrow.hide()
	target_index = 0
	update_target_visuals()

func update_target_visuals() -> void:
	for enemy in active_enemies:
		if enemy.turn_arrow: enemy.turn_arrow.hide()
	
	if active_enemies.size() > 0:
		var target = active_enemies[target_index]
		if target.turn_arrow: target.turn_arrow.show()

func _input(event: InputEvent) -> void:
	if not is_targeting: return
	if event.is_action_pressed("ui_down"):
		target_index = (target_index + 1) % active_enemies.size()
		update_target_visuals()
	elif event.is_action_pressed("ui_up"):
		target_index = (target_index - 1 + active_enemies.size()) % active_enemies.size()
		update_target_visuals()
		
	elif event.is_action_pressed("ui_accept"):
		is_targeting = false
		execute_targeted_attack()
	
	elif event.is_action_pressed("ui_cancel"):
		is_targeting = false
		for enemy in active_enemies:
			if enemy.turn_arrow: enemy.turn_arrow.hide()
			menu_arrow.hide()
		var first_btn = action_menu.get_child(0)
		if first_btn:
			first_btn.grab_focus()

func execute_targeted_attack() -> void:
	action_menu.hide()
	var current_actor: Actor = turn_queue[current_actor_index]
	var target = active_enemies[target_index]
	
	if target.turn_arrow: target.turn_arrow.hide()
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " attacks " + target.character_name + "![/color]")
	target.take_damage(current_actor.base_attack)
	current_actor.action_logged.emit("[color=black]>dealing " + str(current_actor.base_attack) + " damage![/color]")
	finish_action()

func execute_aoe_attack() -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + current_actor.attack_name + " on EVERYONE![/color]")
	
	for enemy in active_enemies:
		enemy.take_damage(current_actor.base_attack)
	current_actor.action_logged.emit("[color=black]>dealing " + str(current_actor.base_attack) + " damage to all![/color]")
	finish_action()

func finish_action() -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	await get_tree().create_timer(1.5).timeout
	current_actor.end_turn()

func _on_actor_turn_finished() -> void:
	current_actor_index += 1
	if current_actor_index >= turn_queue.size():
		current_actor_index = 0
	start_next_turn()

func _on_actor_logged(text: String) -> void:
	if battle_log != null:
		battle_log.append_text(text + "\n")
