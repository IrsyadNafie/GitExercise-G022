extends CanvasLayer

var health_price = 3
var strength_price = 4

var selected_items = {
	"Health": 0,
	"Strength": 0
}

func _ready():
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("open_shop"):
		visible = !visible
		update_ui()

# =========================
# BUTTON CONTROLS
# =========================

func _on_health_plus_btn_pressed():
	selected_items["Health"] += 1
	update_ui()

func _on_health_minus_btn_pressed():
	if selected_items["Health"] > 0:
		selected_items["Health"] -= 1
	update_ui()

func _on_strength_plus_btn_pressed():
	selected_items["Strength"] += 1
	update_ui()

func _on_strength_minus_btn_pressed():
	if selected_items["Strength"] > 0:
		selected_items["Strength"] -= 1
	update_ui()

# =========================
# UI UPDATE
# =========================

func update_ui():
	var h = selected_items["Health"]
	var s = selected_items["Strength"]

	$Panel/QuantityLabel.text = "Health: " + str(h) + " | Strength: " + str(s)

	var total = h * health_price + s * strength_price
	$Panel/TotalCost.text = "Total: " + str(total)

# =========================
# CONFIRM PURCHASE
# =========================

func _on_confirm_btn_pressed():
	var total = selected_items["Health"] * health_price + selected_items["Strength"] * strength_price

	if GameManager.coins >= total:
		GameManager.coins -= total
		print("Purchase Successful")

		spawn_crate()
		print("CONFIRM PRESSED")
		print("SPAWNING CRATE")

		# reset selection
		selected_items["Health"] = 0
		selected_items["Strength"] = 0
		update_ui()
	else:
		print("Not enough money")

# =========================
# SPAWN CRATE (ONLY SPAWN)
# =========================

func spawn_crate():
	var crate_scene = preload("res://LevelFeatures/crate.tscn")
	var crate = crate_scene.instantiate()

	# Spawn above player
	var player = get_parent().get_node("Player")
	crate.global_position = player.global_position + Vector2(0, -500)

	# Add purchased items into crate
	for i in range(selected_items["Health"]):
		crate.stored_items.append("Potion")

	for i in range(selected_items["Strength"]):
		crate.stored_items.append("Axe")  # or "StrengthPotion"

	get_tree().current_scene.add_child(crate)

# =========================
# CLOSE SHOP
# =========================

func _on_close_btn_pressed():
	visible = false
