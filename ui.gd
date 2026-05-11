extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var item_name = $ItemName
@onready var full_message = $FullMessage
@onready var fade = $Fade

func _ready():
	connect_slots()
	update_inventory()

func _process(delta):
	coin_label.text = "Coins: " + str(GameManager.coins)

	# Number keys 1 to 5
	if Input.is_action_just_pressed("slot_1"):
		GameManager.selected_slot = 0
		update_inventory()

	if Input.is_action_just_pressed("slot_2"):
		GameManager.selected_slot = 1
		update_inventory()

	if Input.is_action_just_pressed("slot_3"):
		GameManager.selected_slot = 2
		update_inventory()

	if Input.is_action_just_pressed("slot_4"):
		GameManager.selected_slot = 3
		update_inventory()

	if Input.is_action_just_pressed("slot_5"):
		GameManager.selected_slot = 4
		update_inventory()

	# Press G to drop
	if Input.is_action_just_pressed("drop_item"):
		drop_item()


# =========================
# SLOT CONNECTION
# =========================
func connect_slots():
	for i in range(5):
		var slot = $Hotbar/Slots.get_child(i)

		slot.mouse_entered.connect(func():
			show_item_name(i)
		)

		slot.mouse_exited.connect(func():
			item_name.text = ""
		)

		slot.gui_input.connect(func(event):
			if event is InputEventMouseButton:
				if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					GameManager.selected_slot = i
					update_inventory()
		)


func show_item_name(index):
	item_name.text = GameManager.inventory[index]


# =========================
# INVENTORY UPDATE
# =========================
func update_inventory():
	for i in range(5):
		var slot = $Hotbar/Slots.get_child(i)
		var icon = slot.get_node("Icon")

		if GameManager.inventory[i] == "Key":
			icon.texture = preload("res://yellowkeygodot.png")

		elif GameManager.inventory[i] == "Potion":
			icon.texture = preload("res://potiongodot.png")

		elif GameManager.inventory[i] == "Axe":
			icon.texture = preload("res://axegodot.png")

		else:
			icon.texture = null

	item_name.text = GameManager.inventory[GameManager.selected_slot]

	get_parent().get_node("Player").update_equipped_item(
		GameManager.inventory[GameManager.selected_slot]
	)


# =========================
# ADD ITEM
# =========================
func add_item(new_item):
	for i in range(5):
		if GameManager.inventory[i] == "":
			GameManager.inventory[i] = new_item
			update_inventory()
			print("Added:", new_item)
			return true

	show_full_message()
	print("Inventory Full")
	return false


# =========================
# INVENTORY FULL MESSAGE
# =========================
func show_full_message():
	full_message.text = "Inventory Full!"
	await get_tree().create_timer(2.0).timeout
	full_message.text = ""


# =========================
# DROP ITEM
# =========================
func drop_item():
	if GameManager.inventory[GameManager.selected_slot] != "":

		var dropped_name = GameManager.inventory[GameManager.selected_slot]

		var pickup_scene = preload("res://pickup_item.tscn")
		var dropped_item = pickup_scene.instantiate()

		dropped_item.item_name = dropped_name

		var player = get_parent().get_node("Player")
		dropped_item.global_position = player.global_position + Vector2(60, 0)

		get_tree().current_scene.add_child(dropped_item)

		GameManager.inventory[GameManager.selected_slot] = ""

		update_inventory()

		print("Dropped:", dropped_name)


# =========================
# CHECK ITEM (FOR CHEST)
# =========================
func has_item(item_name):
	for item in GameManager.inventory:
		if item == item_name:
			return true
	return false


# =========================
# REMOVE ITEM (FOR CHEST)
# =========================
func remove_item(item_name):
	for i in range(5):
		if GameManager.inventory[i] == item_name:
			GameManager.inventory[i] = ""
			update_inventory()
			print("Removed:", item_name)
			return true
	return false


# =========================
# FADE SYSTEM
# =========================
func fade_out():
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 0.0, 0.5)
	await tween.finished
