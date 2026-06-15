extends Node


var coins = 20
var checkpoint_position = Vector2.ZERO
var last_overworld_scene: String = ""
var last_player_position: Vector2 = Vector2.ZERO
var enemy_just_defeated: String = ""
var collected_coins: Array[String] = []
var defeated_enemies: Array[String] = []
var just_fled: bool = false

# 5 inventory slots
var inventory = ["", "", "", "", ""]

# which slot is equipped
var selected_slot = 0
