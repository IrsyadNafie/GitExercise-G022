class_name Actor
extends Node2D

signal turn_finished
signal action_logged(text_to_display: String)

@export var character_name: String = "Player"
@export var is_player: bool = true
@export var max_hp: int = 100
@export var max_sp: int = 50

var current_hp: int
var current_sp: int

@onready var hp_bar: ProgressBar = get_node_or_null("HPBar")
@onready var sp_bar: ProgressBar = get_node_or_null("SPBar")

@onready var turn_arrow: Node2D = get_node_or_null("TurnArrow")

func _ready() -> void:
	current_hp = max_hp
	current_sp = max_sp
	
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if sp_bar:
		sp_bar.max_value = max_sp
		sp_bar.value = current_sp

	if turn_arrow:
		turn_arrow.hide()

func start_turn() -> void:
	print("--- " + character_name + "'s Turn ---")

	if turn_arrow:
		turn_arrow.show()
func end_turn() -> void:
	if turn_arrow:
		turn_arrow.hide()
	emit_signal("turn_finished")
