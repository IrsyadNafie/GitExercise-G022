extends CanvasLayer

@onready var item_name = $ItemName
@onready var full_message = $FullMessage
@onready var fade = $Fade
@onready var save_menu = $SaveMenu
@onready var save_message = $SaveMenu/SaveMessage
@onready var interaction_label = $InteractionLabel
@onready var irsyad_health_bar = get_node_or_null("IrsyadHealthBar")
@onready var coin_label = $CoinLabel
@onready var coin_label = $CoinPanel/CoinLabel
@onready var irsyad_health_bar = $IrsyadHealthBar

func _ready():
	connect_slots()
	update_inventory()
	save_menu.visible = false
	interaction_label.text = ""
	

func _process(delta):
	coin_label.text = "🪙 " + str(GameManager.coins)

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

	if Input.is_action_just_pressed("open_save_menu"):
		save_menu.visible = !save_menu.visible

	if Input.is_action_just_pressed("drop_item"):
		drop_item()

# Health Bar
func update_irsyad_health_bar(current_health):
	if irsyad_health_bar:
		irsyad_health_bar.value = clamp(current_health, 0, 100)
	

# =========================
# INTERACTION PROMPT
# =========================
func show_interaction(text):
	interaction_label.text = text

func hide_interaction():
	interaction_label.text = ""


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
			icon.texture = preload("res://InteractableObjects/yellowkeygodot.png")

		elif GameManager.inventory[i] == "Potion":
			icon.texture = preload("res://potiongodot.png")

		elif GameManager.inventory[i] == "Axe":
			icon.texture = preload("res://InteractableObjects/axegodot.png")

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

		var pickup_scene = preload("res://LevelFeatures/pickup_item.tscn")
		var dropped_item = pickup_scene.instantiate()

		dropped_item.item_name = dropped_name

		var player = get_parent().get_node("Player")
		dropped_item.global_position = player.global_position + Vector2(60, 0)

		get_tree().current_scene.add_child(dropped_item)

		GameManager.inventory[GameManager.selected_slot] = ""
		update_inventory()

		print("Dropped:", dropped_name)


# =========================
# ITEM CHECKING
# =========================
func has_item(item_name):
	for item in GameManager.inventory:
		if item == item_name:
			return true
	return false


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


# =========================
# SAVE / LOAD
# =========================
func _on_save_slot_1_btn_pressed():
	SaveManager.save_game(1)
	show_save_message("Saved Slot 1!")


func _on_load_slot_1_btn_pressed():
	SaveManager.load_game(1)


func _on_save_slot_2_btn_pressed():
	SaveManager.save_game(2)
	show_save_message("Saved Slot 2!")


func _on_load_slot_2_btn_pressed():
	SaveManager.load_game(2)


func _on_save_slot_3_btn_pressed():
	SaveManager.save_game(3)
	show_save_message("Saved Slot 3!")


func _on_load_slot_3_btn_pressed():
	SaveManager.load_game(3)


func _on_close_save_btn_pressed():
	save_menu.visible = false


func show_save_message(text):
	save_message.text = text
	await get_tree().create_timer(2.0).timeout
	save_message.text = ""
