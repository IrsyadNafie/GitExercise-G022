extends Node2D

var turn_queue: Array[Actor] = []
var current_actor_index: int = 0

var active_enemies: Array[Actor] = []
var is_targeting: bool = false
var is_targeting_ally: bool = false
var target_index: int = 0
var total_battle_exp: int = 0
var battle_won: bool = false
var is_ending_turn: bool = false

var is_in_skill_menu: bool = false
var current_skills: Array[Skill] = []
var selected_skill_to_execute: Skill = null

@onready var menu_arrow = $UI/PlayerPanel/arrow
@onready var ui_layer = $UI
@onready var action_menu = $UI/PlayerPanel/move
@onready var battle_log = $UI/PlayerPanel/BattleLog/RichTextLabel
@export var burn_status_resource: StatusEffect

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
			node.action_logged.connect(_on_actor_logged)
			
			if not node.is_player:
				active_enemies.append(node)
	_on_actor_logged("Battle Start!")
	start_next_turn()

func start_next_turn() -> void:
	is_in_skill_menu = false
	selected_skill_to_execute = null
	
	if turn_queue.size() == 0: return
	
	var current_actor: Actor = turn_queue[current_actor_index]
	_on_actor_logged("[color=red]---- " + current_actor.character_name + " turn ----[/color]")
	current_actor.start_turn()
	var is_stunned = current_actor.process_statuses()
	
	if current_actor.current_hp <= 0:
		check_death(current_actor)
		if battle_won: return
		finish_action()
		return
		
	if is_stunned:
		finish_action()
		return
	
	if current_actor.is_player:
		reset_main_menu(current_actor)
		var first_btn = action_menu.get_child(0)
		if first_btn:
			first_btn.text = current_actor.attack_name
		action_menu.show()
		menu_arrow.show()
		if first_btn:
			first_btn.grab_focus()
	else:
		action_menu.hide()
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()

func _on_ui_action_selected(action: String) -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	
	if is_in_skill_menu:
		handle_skill_choice(action)
		return
		
	if action == "special":
		open_skill_sub_menu(current_actor)
	elif action == current_actor.attack_name or action == "attack":
		selected_skill_to_execute = null
		
		if current_actor.is_aoe_attack:
			menu_arrow.hide()
			action_menu.hide()
			execute_aoe_attack()
		else:
			get_viewport().gui_release_focus()
			await get_tree().process_frame
			start_targeting()
			
	elif action == "rest":
		menu_arrow.hide()
		action_menu.hide()
		@warning_ignore("integer_division")
		var sp_regain = (current_actor.max_sp * 30) / 100
		if sp_regain < 1: sp_regain = 1
		current_actor.current_sp += sp_regain
		if current_actor.current_sp > current_actor.max_sp:
			current_actor.current_sp = current_actor.max_sp
		current_actor.update_bars()
		current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " rests...[/color]")
		finish_action()

func execute_targeted_ally() -> void:
	action_menu.hide()
	var current_actor: Actor = turn_queue[current_actor_index]
	var target = get_active_players()[target_index]
	if target.turn_arrow: target.turn_arrow.hide()
	current_actor.current_sp -= selected_skill_to_execute.sp_cost
	current_actor.update_bars()
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + selected_skill_to_execute.name + " on " + target.character_name + "![/color]")
	if selected_skill_to_execute.heal_amount > 0:
		target.current_hp = min(target.current_hp + selected_skill_to_execute.heal_amount, target.max_hp)
		current_actor.action_logged.emit("[color=green]>Restored HP![/color]")
	else:
		current_actor.action_logged.emit("[color=blue]>" + target.character_name + " is boosted![/color]")
	if selected_skill_to_execute.status_to_apply:
		target.apply_status(selected_skill_to_execute.status_to_apply)
	target.update_bars()
	selected_skill_to_execute = null
	finish_action()

func handle_skill_choice(action: String):
	var current_actor: Actor = turn_queue[current_actor_index]
	var selected: Skill = null
	var clicked_index = -1
	for i in range(action_menu.get_child_count()):
		var btn = action_menu.get_child(i)
		if action == btn.name or action == btn.text:
			clicked_index = i
			break
	if clicked_index != -1 and clicked_index < current_skills.size():
		selected = current_skills[clicked_index]
	if selected:
		if current_actor.current_sp >= selected.sp_cost:
			selected_skill_to_execute = selected
			is_in_skill_menu = false 
			if selected.target_type == Skill.TargetType.SINGLE_ENEMY:
				action_menu.hide()
				get_viewport().gui_release_focus()
				await get_tree().process_frame 
				start_targeting(false)
			elif selected.target_type == Skill.TargetType.SINGLE_ALLY:
				action_menu.hide()
				get_viewport().gui_release_focus()
				await get_tree().process_frame 
				start_targeting(true)
			else: 
				current_actor.current_sp -= selected.sp_cost
				current_actor.update_bars()
				if selected.target_type == Skill.TargetType.ALL_ENEMY:
					action_menu.hide()
					menu_arrow.hide()
					execute_aoe_skill(selected)
				elif selected.target_type == Skill.TargetType.SELF:
					action_menu.hide()
					menu_arrow.hide()
					execute_self_skill(selected)
				elif selected.target_type == Skill.TargetType.RANDOM:
					action_menu.hide()
					menu_arrow.hide()
					execute_random_skill(selected)
				else:
					action_menu.hide()
					execute_party_heal(selected)
		else:
			_on_actor_logged("[color=red]>Not enough SP![/color]")

func get_active_players() -> Array[Actor]:
	var players: Array[Actor] = []
	for actor in turn_queue:
		if actor.is_player and actor.current_hp > 0:
			players.append(actor)
	return players

func start_targeting(targeting_ally: bool = false) -> void:
	is_targeting = true
	is_targeting_ally = targeting_ally
	menu_arrow.hide()
	target_index = 0
	update_target_visuals()

func update_target_visuals() -> void:
	for enemy in active_enemies:
		if enemy.turn_arrow: enemy.turn_arrow.hide()
	for player in get_active_players():
		if player.turn_arrow: player.turn_arrow.hide()
	if is_targeting_ally:
		var players = get_active_players()
		if players.size() > 0:
			var target = players[target_index]
			if target.turn_arrow: target.turn_arrow.show()
	else:
		if active_enemies.size() > 0:
			var target = active_enemies[target_index]
			if target.turn_arrow: target.turn_arrow.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_targeting:
			is_targeting = false
			for enemy in active_enemies:
				if enemy.turn_arrow: enemy.turn_arrow.hide()
			for player in get_active_players():
				if player.turn_arrow: player.turn_arrow.hide()
			action_menu.show()
			menu_arrow.show()
			action_menu.get_child(0).grab_focus()
		elif is_in_skill_menu:
			is_in_skill_menu = false
			reset_main_menu(turn_queue[current_actor_index])
			action_menu.get_child(0).grab_focus()
		return
		
	if not is_targeting: return
	
	var target_list = get_active_players() if is_targeting_ally else active_enemies
	
	if event.is_action_pressed("ui_down"):
		target_index = (target_index + 1) % target_list.size()
		update_target_visuals()
	elif event.is_action_pressed("ui_up"):
		target_index = (target_index - 1 + target_list.size()) % target_list.size()
		update_target_visuals()
	elif event.is_action_pressed("ui_accept"):
		is_targeting = false
		if is_targeting_ally:
			execute_targeted_ally()
		else:
			execute_targeted_attack()

func execute_targeted_attack() -> void:
	action_menu.hide()
	var current_actor: Actor = turn_queue[current_actor_index]
	var target = active_enemies[target_index]
	if target.turn_arrow: target.turn_arrow.hide()
	
	var dmg = current_actor.base_attack
	var msg = " attacks "
	var hits = 1
	
	if selected_skill_to_execute:
		current_actor.current_sp -= selected_skill_to_execute.sp_cost
		current_actor.update_bars()
		dmg = selected_skill_to_execute.damage
		msg = " uses " + selected_skill_to_execute.name + " on "
		hits = selected_skill_to_execute.hits
		if selected_skill_to_execute.name == "heavy-arrow":
			if randf() < 0.3:
				_on_actor_logged(">The arrow flew wide! MISS!")
				selected_skill_to_execute = null
				finish_action()
				return
				
	var has_magic_sword = current_actor.is_enchanted()
	if has_magic_sword:
		dmg += 3
		msg = " strikes with a FLAMING weapon at "
		
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + msg + target.character_name + "![/color]")
	
	for i in range(hits):
		var final_dmg = dmg
		if randf() <= current_actor.crit_chance:
			final_dmg = int(final_dmg * current_actor.crit_multiplier)
			current_actor.action_logged.emit("[color=red]>CRITICAL HIT![/color]")
			
		target.take_damage(final_dmg)
		
		if selected_skill_to_execute and selected_skill_to_execute.status_to_apply:
			target.apply_status(selected_skill_to_execute.status_to_apply)
		if has_magic_sword and burn_status_resource:
			target.apply_status(burn_status_resource)
			
		check_death(target)
		if hits > 1: await get_tree().create_timer(0.2).timeout
		
	finish_action() # ONLY ONE CALL HERE NOW

func execute_aoe_attack() -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + current_actor.attack_name + " on EVERYONE![/color]")
	current_actor.action_logged.emit("[color=black]>dealing " + str(current_actor.base_attack) + " damage to all![/color]")
	
	var enemies_to_hit = active_enemies.duplicate()
	for enemy in enemies_to_hit:
		if is_instance_valid(enemy) and enemy.current_hp > 0:
			enemy.take_damage(current_actor.base_attack)
			check_death(enemy)
			
	finish_action()

func execute_aoe_skill(skill: Skill):
	var current_actor: Actor = turn_queue[current_actor_index]
	if skill.name == "Run with Fierce":
		current_actor.current_sp = 0
		current_actor.update_bars()
		_on_actor_logged(">Draining all SP for a massive strike!")
	
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + skill.name + "![/color]")
	
	var targets = active_enemies.duplicate()
	
	for i in range(skill.hits):
		for enemy in targets:
			if enemy.current_hp > 0:
				enemy.take_damage(skill.damage)
				check_death(enemy)
		
		if skill.hits > 1: 
			await get_tree().create_timer(0.2).timeout
	
	finish_action()

func execute_party_heal(skill: Skill):
	var current_actor: Actor = turn_queue[current_actor_index]
	_on_actor_logged(">" + current_actor.character_name + " uses " + skill.name + "!")
	
	for actor in turn_queue:
		if actor.is_player:
			# Apply healing
			if skill.heal_amount > 0:
				actor.current_hp = min(actor.current_hp + skill.heal_amount, actor.max_hp)
			
			if skill.name == "rally" or skill.name == "safeguard":
				_on_actor_logged(">" + actor.character_name + " feels boosted!")
				
			actor.update_bars()
	finish_action()

func finish_action() -> void:
	if is_ending_turn or battle_won: return
	is_ending_turn = true
	
	clear_all_arrows()
	
	var current_actor: Actor = turn_queue[current_actor_index]
	await get_tree().create_timer(1.5).timeout
	
	if is_instance_valid(current_actor):
		current_actor.end_turn()
		
	current_actor_index += 1
	if current_actor_index >= turn_queue.size():
		current_actor_index = 0
		
	is_ending_turn = false
	start_next_turn()

func _on_actor_turn_finished() -> void:
	current_actor_index += 1
	if current_actor_index >= turn_queue.size():
		current_actor_index = 0
	start_next_turn()

func _on_actor_logged(text: String) -> void:
	if battle_log != null:
		battle_log.append_text(text + "\n")

func check_death(target: Actor) -> void:
	if target.current_hp <= 0:
		_on_actor_logged("[color=yellow]>" + target.character_name + " was defeated.[/color]")
		if not target.is_player:
			total_battle_exp += target.exp_reward
		if active_enemies.has(target):
			active_enemies.erase(target)
		var dead_index = turn_queue.find(target)
		if dead_index != -1:
			if dead_index < current_actor_index:
				current_actor_index -= 1
			turn_queue.erase(target)
		target.hide()
		if active_enemies.size() == 0:
			_on_actor_logged("[color=green]>Purified.[/color]")
			distribute_victory_exp()

func open_skill_sub_menu(actor: Actor):
	if actor.skills.size() == 0: return
	is_in_skill_menu = true
	current_skills = actor.skills
	
	for i in range(action_menu.get_child_count()):
		var btn = action_menu.get_child(i)
		if i < actor.skills.size():
			var s = actor.skills[i]
			if s != null:
				btn.text = s.name + " (" + str(s.sp_cost) + "SP)"
				btn.show()
			else:
				btn.hide()
		else:
			btn.hide()
			
	action_menu.get_child(0).grab_focus()

func reset_main_menu(actor: Actor):
	var labels = [actor.attack_name, "rest", "special", "item", "flee"]
	for i in range(action_menu.get_child_count()):
		var btn = action_menu.get_child(i)
		if i < labels.size():
			btn.text = labels[i]
			btn.show()
		else:
			btn.hide()

func clear_all_arrows() -> void:
	for enemy in active_enemies:
		if enemy.turn_arrow: enemy.turn_arrow.hide()
	for player in get_active_players():
		if player.turn_arrow: player.turn_arrow.hide()

func execute_self_skill(skill: Skill) -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + skill.name + "![/color]")
	
	if skill.heal_amount > 0:
		current_actor.current_hp = min(current_actor.current_hp + skill.heal_amount, current_actor.max_hp)
		current_actor.action_logged.emit("[color=green]>Restored HP![/color]")
	else:
		current_actor.action_logged.emit("[color=blue]>" + current_actor.character_name + " is boosted![/color]")
		
	if skill.status_to_apply:
		current_actor.apply_status(skill.status_to_apply)
		
	current_actor.update_bars()
	selected_skill_to_execute = null
	finish_action()

func execute_random_skill(skill: Skill) -> void:
	var current_actor: Actor = turn_queue[current_actor_index]
	if active_enemies.size() == 0:
		finish_action()
		return
	current_actor.action_logged.emit("[color=black]>" + current_actor.character_name + " uses " + skill.name + "![/color]")
	for i in range(skill.hits):
		if active_enemies.size() > 0:
			var random_index = randi() % active_enemies.size()
			var target = active_enemies[random_index]
			
			current_actor.action_logged.emit(">It randomly strikes " + target.character_name + "!")
			target.take_damage(skill.damage)
			check_death(target)
			
		if skill.hits > 1: await get_tree().create_timer(0.7).timeout
		
	selected_skill_to_execute = null
	finish_action()

func distribute_victory_exp() -> void:
	battle_won = true
	action_menu.hide()
	menu_arrow.hide()
	
	_on_actor_logged("[color=yellow]>Battle Won! Earned " + str(total_battle_exp) + " EXP![/color]")
	
	for player in get_active_players():
		player.gain_exp(total_battle_exp)
		
	await get_tree().create_timer(4.0).timeout
	
	_on_actor_logged(">Returning to map...")

func execute_enemy_ai() -> void:
	if is_ending_turn or battle_won: return
	var current_actor: Actor = turn_queue[current_actor_index]
	
	var players = get_active_players()
	if players.size() == 0:
		finish_action()
		return
		
	var decision = current_actor.execute_ai(players, active_enemies)
	var target: Actor = decision["target"]
	var skill: Skill = decision["skill"]
	if current_actor.turn_arrow: current_actor.turn_arrow.hide()
	var is_basic_aoe = (decision["action"] == "attack" and current_actor.is_aoe_attack)
	
	if is_basic_aoe:
		for p in players:
			if p.turn_arrow: p.turn_arrow.show()
	elif target and is_instance_valid(target) and target.turn_arrow:
		target.turn_arrow.show()
		
	await get_tree().create_timer(1.0).timeout 
	
	if is_basic_aoe:
		for p in players:
			if p.turn_arrow: p.turn_arrow.hide()
	elif target and is_instance_valid(target) and target.turn_arrow:
		target.turn_arrow.hide()
		
	if decision["action"] == "attack":
		if current_actor.is_aoe_attack:
			
			_on_actor_logged("[color=black]>" + current_actor.character_name + " attacks EVERYONE![/color]")
			for p in players:
				var dmg = current_actor.base_attack
				if randf() <= current_actor.crit_chance:
					dmg = int(dmg * current_actor.crit_multiplier)
				p.take_damage(dmg)
				check_death(p)
		else:
			
			_on_actor_logged("[color=black]>" + current_actor.character_name + " attacks " + target.character_name + "![/color]")
			var dmg = current_actor.base_attack
			if randf() <= current_actor.crit_chance:
				dmg = int(dmg * current_actor.crit_multiplier)
				_on_actor_logged("[color=red]>CRITICAL HIT![/color]")
			target.take_damage(dmg)
			check_death(target)
		
	elif decision["action"] == "skill":
		current_actor.current_sp -= skill.sp_cost
		current_actor.update_bars()
		
		if skill.target_type == Skill.TargetType.SINGLE_ENEMY or skill.target_type == Skill.TargetType.RANDOM:
			_on_actor_logged("[color=black]>" + current_actor.character_name + " uses " + skill.name + " on " + target.character_name + "![/color]")
			for i in range(skill.hits):
				target.take_damage(skill.damage)
				if skill.status_to_apply: target.apply_status(skill.status_to_apply)
				check_death(target)
				if skill.hits > 1: await get_tree().create_timer(0.2).timeout
				
		elif skill.target_type == Skill.TargetType.ALL_ENEMY:
			_on_actor_logged("[color=black]>" + current_actor.character_name + " uses " + skill.name + " on EVERYONE![/color]")
			for p in players:
				p.take_damage(skill.damage)
				if skill.status_to_apply: p.apply_status(skill.status_to_apply)
				check_death(p)
				
		elif skill.target_type == Skill.TargetType.SINGLE_ALLY or skill.target_type == Skill.TargetType.SELF:
			_on_actor_logged("[color=black]>" + current_actor.character_name + " uses " + skill.name + " on " + target.character_name + "![/color]")
			if skill.heal_amount > 0:
				target.current_hp = min(target.current_hp + skill.heal_amount, target.max_hp)
				_on_actor_logged("[color=green]>Restored HP![/color]")
			if skill.status_to_apply: target.apply_status(skill.status_to_apply)
			target.update_bars()
			
	finish_action()
