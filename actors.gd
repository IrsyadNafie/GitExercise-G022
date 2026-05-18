class_name Actor
extends Node2D

signal turn_finished
signal action_logged(text_to_display: String)

@export_category("Identity")
@export var character_name: String = "Player"
@export var is_player: bool = true
@export var attack_name: String = "attack"
@export var is_aoe_attack: bool = false

@export_category("Battle Stats")
@export var max_hp: int = 10
@export var max_sp: int = 5
@export var base_attack: int = 3
@export var sp_attack: int = 5

@export var crit_chance: float = 0.5
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

func _ready() -> void:
	current_hp = max_hp
	current_sp = max_sp
	update_bars()
		
	if turn_arrow:
		turn_arrow.hide()

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
func gain_exp(amount: int) -> void:
	if level >= 5:
		return
	current_exp += amount
	action_logged.emit("[color=cyan]>" + character_name + " gained " + str(amount) + " EXP![/color]")
	while current_exp >= max_exp and level < 5:
		level_up()

func level_up() -> void:
	current_exp -= max_exp
	level += 1
	max_exp = int(max_exp * 1.5)
	max_hp += 5
	max_sp += 3
	base_attack += 2
	sp_attack += 2 
	current_hp = max_hp 
	current_sp = max_sp
	update_bars()
	action_logged.emit("[color=gold]>LEVEL UP! " + character_name + " is now Level " + str(level) + "![/color]")

func take_damage(amount: int) -> void:
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	update_bars()

func apply_status(new_effect: StatusEffect) -> void:
	active_statuses.append({
		"effect": new_effect,
		"turns_left": new_effect.duration
	})
	action_logged.emit("[color=purple]>" + character_name + " was inflicted with " + new_effect.name + "![/color]")
	
	update_status_ui()

func process_statuses() -> bool:
	var is_stunned = false
	
	for i in range(active_statuses.size() - 1, -1, -1):
		var status = active_statuses[i]
		var effect = status["effect"]
		
		if effect.type == StatusEffect.EffectType.FIRE:
			take_damage(effect.amount)
			action_logged.emit("[color=orange]>" + character_name + " takes " + str(effect.amount) + " damage from " + effect.name + "![/color]")
			
		elif effect.type == StatusEffect.EffectType.STUN:
			is_stunned = true
			action_logged.emit("[color=yellow]>" + character_name + " is paralyzed by " + effect.name + " and cannot move![/color]")
		
		if not effect.is_permanent:
			status["turns_left"] -= 1
			if status["turns_left"] <= 0:
				action_logged.emit("[color=gray]>" + effect.name + " wore off on " + character_name + ".[/color]")
				active_statuses.remove_at(i)
			
	update_status_ui()
	
	return is_stunned

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
