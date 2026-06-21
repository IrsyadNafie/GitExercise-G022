extends Node

var coins = 20
var checkpoint_position = Vector2.ZERO
var load_player_position = Vector2.ZERO
var picked_items = []

# 5 inventory slots
var inventory = ["", "", "", "", ""]

# which slot is equipped
var selected_slot = 0
