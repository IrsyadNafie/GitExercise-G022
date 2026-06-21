extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var item_name = $ItemName
@onready var full_message = $FullMessage

var inventory = ["Key", "Potion", "", "", ""]
var selected_slot = 0

func _ready():
	connect_slots()
	update_inventory()

func _process(delta):
	coin_label.text = "Coins: " + str(GameManager.coins)

	# Quick swap by keyboard
	if Input.is_key_pressed(KEY_1):
		selected_slot = 0
		update_inventory()

	if Input.is_key_pressed(KEY_2):
		selected_slot = 1
		update_inventory()

	# Drop item
	if Input.is_action_just_pressed("drop_item"):
		drop_item()

func connect_slots():
	for i in range(5):
		var slot = $Hotbar/Slots.get_child(i)

		# Hover mouse
		slot.mouse_entered.connect(func():
			show_item_name(i)
		)

		slot.mouse_exited.connect(func():
			item_name.text = ""
		)

		# Click slot
		slot.gui_input.connect(func(event):
			if event is InputEventMouseButton:
				if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					selected_slot = i
					update_inventory()
		)

func show_item_name(index):
	item_name.text = inventory[index]

func update_inventory():
	for i in range(5):
		var slot = $Hotbar/Slots.get_child(i)
		var icon = slot.get_node("Icon")

		if inventory[i] == "Key":
			icon.texture = preload("res://yellowkeygodot.png")

		elif inventory[i] == "Potion":
			icon.texture = preload("res://potiongodot.png")

		else:
			icon.texture = null

	item_name.text = inventory[selected_slot]
	get_parent().get_node("Player").update_equipped_item(inventory[selected_slot])

func add_item(new_item):
	for i in range(5):
		if inventory[i] == "":
			inventory[i] = new_item
			update_inventory()
			return

	show_full_message()

func show_full_message():
	full_message.text = "Inventory Full!"
	await get_tree().create_timer(2.0).timeout
	full_message.text = ""

func drop_item():
	if inventory[selected_slot] != "":
		inventory[selected_slot] = ""
		update_inventory()
