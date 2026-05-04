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

@export_category("Progression")
@export var level: int = 1
@export var current_exp: int = 0
@export var max_exp: int = 10
@export var exp_reward: int = 5

var current_hp: int
var current_sp: int

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
