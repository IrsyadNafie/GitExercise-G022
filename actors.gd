class_name Actor
extends Node2D

signal turn_finished
signal action_logged(text_to_display: String)

var base_sprite_x: float = 0.0
var sway_timer: float = 0.0
var sway_speed: float = 2.0

@export_category("Combat Audio")
@export var basic_attack_sound: AudioStream
@export var hurt_sound: AudioStream
@onready var sfx_player = get_node_or_null("SFXPlayer")

@export_category("Identity")
@export var character_name: String = "Player"
@export var is_player: bool = true
@export var attack_name: String = "attack"
@export var is_aoe_attack: bool = false
@export var visual_sprite: CanvasItem
@export var is_static_attacker: bool = false

@export_category("Battle Stats")
@export var max_hp: int = 10
@export var max_sp: int = 5
@export var base_attack: int = 3
@export var sp_attack: int = 5

@export var crit_chance: float = 0.2
@export var crit_multiplier: float = 1.5

@export_category("Progression")
@export var level: int = 1
@export var current_exp: int = 0
@export var max_exp: int = 10
@export var exp_reward: int = 5

var current_hp: int
var current_sp: int
var active_statuses: Array[Dictionary] = []

@onready var status_container: HBoxContainer = get_node_or_null("StatusContainer")
@onready var hp_bar: ProgressBar = get_node_or_null("HPBar")
@onready var sp_bar: ProgressBar = get_node_or_null("SPBar")
@onready var turn_arrow: Node2D = get_node_or_null("TurnArrow")
@export var skills: Array[Skill] = []
@export var learnable_skills: Array[Skill] = []

func _ready() -> void:
	if is_player and GameManager.party_level > level:
		apply_level_stats(GameManager.party_level)
	else:
		current_hp = max_hp
		current_sp = max_sp
		update_bars()
		refresh_skills()
	sway_timer = randf_range(0.0, 100.0)
	sway_speed = randf_range(1.5, 2.5)
	
	current_hp = max_hp
	current_sp = max_sp
	update_bars()
	
	if turn_arrow:
		turn_arrow.hide()
		
	await get_tree().process_frame
	if visual_sprite:
		base_sprite_x = visual_sprite.position.x
		
	refresh_skills()

func refresh_skills() -> void:
	skills.clear()
	for i in range(min(level, learnable_skills.size())):
		if learnable_skills[i] != null:
			skills.append(learnable_skills[i])

func update_bars() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if sp_bar:
		sp_bar.max_value = max_sp
		sp_bar.value = current_sp

func start_turn() -> void:
	if turn_arrow: turn_arrow.show()

func end_turn() -> void:
	if turn_arrow: turn_arrow.hide()
	emit_signal("turn_finished")

# exp level up
func apply_level_stats(new_level: int) -> void:
	var diff = new_level - level
	if diff <= 0:
		return
		
	level = new_level
	max_hp += (5 * diff)
	max_sp += (3 * diff)
	base_attack += (2 * diff)
	sp_attack += (2 * diff)
	
	current_hp = max_hp 
	current_sp = max_sp
	update_bars()
	refresh_skills()

func take_damage(amount: int) -> void:
	print("--- HIT DETECTED ---")
	print(character_name + " was hit for " + str(amount) + " damage!")
	print("HP BEFORE: " + str(current_hp) + " / " + str(max_hp))
	
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
		
	print("HP AFTER: " + str(current_hp) + " / " + str(max_hp))
	print("--------------------")
	
	update_bars()
	
	var indicator_scene = preload("res://damage_indicator.tscn")
	var indicator = indicator_scene.instantiate()
	indicator.damage_amount = amount
	get_tree().current_scene.add_child(indicator)
	
	if visual_sprite:
		if "size" in visual_sprite:
			indicator.global_position = visual_sprite.global_position + Vector2(visual_sprite.size.x / 2.0, -25)
		else:
			indicator.global_position = visual_sprite.global_position + Vector2(0, -25)
	else:
		indicator.global_position = self.global_position + Vector2(0, -25)
		
	if visual_sprite:
		visual_sprite.modulate = Color(0.6, 0.0, 0.0) 
		
		var hit_tween = create_tween()
		
		if "offset" in visual_sprite:
			visual_sprite.offset = Vector2.ZERO 
			hit_tween.tween_property(visual_sprite, "offset", Vector2(-8, -15), 0.05)
			hit_tween.tween_property(visual_sprite, "offset", Vector2(8, -5), 0.05)
			hit_tween.tween_property(visual_sprite, "offset", Vector2(6, -5), 0.05)
			hit_tween.tween_property(visual_sprite, "offset", Vector2(-6, 0), 0.05)
			hit_tween.tween_property(visual_sprite, "offset", Vector2(0, 0), 0.05)
			
		else:
			var base_pos = visual_sprite.position
			hit_tween.tween_property(visual_sprite, "position", base_pos + Vector2(-8, -15), 0.05)
			hit_tween.tween_property(visual_sprite, "position", base_pos + Vector2(8, -5), 0.05)
			hit_tween.tween_property(visual_sprite, "position", base_pos + Vector2(6, -5), 0.05)
			hit_tween.tween_property(visual_sprite, "position", base_pos + Vector2(-6, 0), 0.05)
			hit_tween.tween_property(visual_sprite, "position", base_pos, 0.05)
		
		var color_tween = create_tween()
		color_tween.tween_property(visual_sprite, "modulate", Color(1, 1, 1), 0.4).set_delay(0.1)
	
	if sfx_player != null and hurt_sound != null:
		sfx_player.stream = hurt_sound
		sfx_player.play()

func apply_status(new_effect: StatusEffect) -> void:
	active_statuses.append({
		"effect": new_effect,
		"turns_left": new_effect.duration
	})
	action_logged.emit("[color=purple]>" + character_name + " was inflicted with " + new_effect.name + "![/color]")
	
	update_status_ui()

func check_if_stunned() -> bool:
	for status in active_statuses:
		if status["effect"].type == StatusEffect.EffectType.STUN:
			action_logged.emit("[color=yellow]>" + character_name + " is paralyzed and cannot move![/color]")
			return true
	return false

func process_end_of_round_statuses() -> void:
	for i in range(active_statuses.size() - 1, -1, -1):
		var status = active_statuses[i]
		var effect = status["effect"]

		if effect.type == StatusEffect.EffectType.FIRE:
			take_damage(effect.amount)
			action_logged.emit("[color=orange]>" + character_name + " takes " + str(effect.amount) + " damage from " + effect.name + "![/color]")

		if not effect.is_permanent:
			status["turns_left"] -= 1
			if status["turns_left"] <= 0:
				action_logged.emit("[color=gray]>" + effect.name + " wore off on " + character_name + ".[/color]")
				active_statuses.remove_at(i)
				
	update_status_ui()

func update_status_ui() -> void:
	if not status_container: 
		return
		
	for child in status_container.get_children():
		child.queue_free()
		
	for status in active_statuses:
		var effect: StatusEffect = status["effect"]
		
		if effect.icon:
			var icon_rect = TextureRect.new()
			icon_rect.texture = effect.icon
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.custom_minimum_size = Vector2(40, 40) 
			status_container.add_child(icon_rect)

func is_enchanted() -> bool:
	for status in active_statuses:
		if status["effect"].type == StatusEffect.EffectType.ENCHANT:
			return true
	return false
	
func execute_ai(players: Array[Actor], allies: Array[Actor]) -> Dictionary:
	var valid_skills: Array[Skill] = []
	for s in skills:
		if s != null and current_sp >= s.sp_cost:
			valid_skills.append(s)

	var decision = {
		"action": "attack",
		"skill": null,
		"target": players.pick_random()
	}

	if valid_skills.size() > 0 and randf() > 0.4:
		var chosen_skill = valid_skills.pick_random()
		decision["action"] = "skill"
		decision["skill"] = chosen_skill
		
		if chosen_skill.target_type == Skill.TargetType.SINGLE_ENEMY:
			decision["target"] = players.pick_random()
		elif chosen_skill.target_type == Skill.TargetType.SINGLE_ALLY:
			decision["target"] = allies.pick_random() # Heals/Buffs another enemy
		elif chosen_skill.target_type == Skill.TargetType.SELF:
			decision["target"] = self
			
	return decision

func _process(delta: float) -> void:
	if is_static_attacker:
		return
		
	if visual_sprite:
		sway_timer += delta
		visual_sprite.position.x = base_sprite_x + (sin(sway_timer * sway_speed) * 2.0)
		
func play_attack_sound(skill_used: Skill = null) -> void:
	if sfx_player == null: return
	if skill_used != null and skill_used.skill_sound != null:
		sfx_player.stream = skill_used.skill_sound
		sfx_player.play()
	elif basic_attack_sound != null:
		sfx_player.stream = basic_attack_sound
		sfx_player.play()

func scale_to_party_level(party_level: int) -> void:
	var level_difference = party_level - level
	
	if level_difference <= 0: 
		return 
		
	level = party_level
	
	max_hp += (5 * level_difference)
	max_sp += (3 * level_difference)
	base_attack += (2 * level_difference)
	sp_attack += (2 * level_difference)
	
	current_hp = max_hp
	current_sp = max_sp
	update_bars()
	refresh_skills()
