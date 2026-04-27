extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var item_name = $ItemName
@onready var full_message = $FullMessage

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

#Inventory update everytime new items added
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

	show_full_message()
	return false


func show_full_message():
	full_message.text = "Inventory Full!"
	await get_tree().create_timer(2.0).timeout
	full_message.text = ""


func drop_item():
	if GameManager.inventory[GameManager.selected_slot] != "":

		# Save item name first
		var dropped_name = GameManager.inventory[GameManager.selected_slot]

		# Load PickupItem scene
		var pickup_scene = preload("res://pickup_item.tscn")

		# Create new item in world
		var dropped_item = pickup_scene.instantiate()

		# Give dropped item its correct name
		dropped_item.item_name = dropped_name

		# Spawn near player
		var player = get_parent().get_node("Player")
		dropped_item.global_position = player.global_position + Vector2(60, 0)

		# Add dropped item into current scene
		get_tree().current_scene.add_child(dropped_item)

		# Remove from inventory
		GameManager.inventory[GameManager.selected_slot] = ""

		# Refresh UI
		update_inventory()

		print("Dropped:", dropped_name)
