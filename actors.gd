class_name Actor
extends Node2D

signal turn_finished

@export var character_name: String = "Player"
@export var is_player: bool = true
@export var max_hp: int = 100
@export var max_sp: int = 50

var current_hp: int
var current_sp: int

# Godot will look for child nodes with exactly these names.
# We use get_node_or_null so the game doesn't crash if an enemy doesn't have an SP bar.
@onready var hp_bar: ProgressBar = get_node_or_null("HPBar")
@onready var sp_bar: ProgressBar = get_node_or_null("SPBar")

func _ready() -> void:
	current_hp = max_hp
	current_sp = max_sp
	
	# Initialize the visual bars at the start of the game
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if sp_bar:
		sp_bar.max_value = max_sp
		sp_bar.value = current_sp

func start_turn() -> void:
	print("--- " + character_name + "'s Turn ---")
	# Because it's a player, we just wait for the BattleManager to show the UI buttons.

func take_damage(amount: int) -> void:
	current_hp -= amount
	
	# Visually update the bar!
	if hp_bar:
		hp_bar.value = current_hp
		
	print(character_name + " took " + str(amount) + " damage!")
	
	if current_hp <= 0:
		die()

func use_special(sp_cost: int) -> bool:
	# Check if we have enough SP to use a special attack
	if current_sp >= sp_cost:
		current_sp -= sp_cost
		if sp_bar:
			sp_bar.value = current_sp
		return true
	else:
		print("Not enough SP!")
		return false

func die() -> void:
	print(character_name + " was defeated!")
	# Removes the character from the game
	queue_free()

func end_turn() -> void:
	emit_signal("turn_finished")
