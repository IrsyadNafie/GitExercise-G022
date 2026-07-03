extends CanvasLayer

@onready var coin_label = $Panel/CoinLabel

const HEALTH_PRICE = 25
const STRENGTH_PRICE = 40
const LUCK_PRICE = 35

func _ready():
	visible = false
	update_coin_label()

func _process(_delta):
	if visible:
		update_coin_label()

func open_shop():
	visible = true
	update_coin_label()
	print("Shop Opened")

func close_shop():
	visible = false
	print("Shop Closed")

func update_coin_label():
	coin_label.text = "Coins: " + str(GameManager.coins)

func inventory_has_space():
	for item in GameManager.inventory:
		if item == "":
			return true
	return false

func add_to_inventory(item_name):
	for i in range(GameManager.inventory.size()):
		if GameManager.inventory[i] == "":
			GameManager.inventory[i] = item_name
			update_main_inventory_ui()
			return true

	return false

func update_main_inventory_ui():
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("update_inventory"):
		ui.update_inventory()

func buy_potion(item_name, price):
	if not inventory_has_space():
		print("Inventory full! Cannot buy.")
		return

	if GameManager.coins < price:
		print("Not enough coins!")
		return

	GameManager.coins -= price
	add_to_inventory(item_name)
	update_coin_label()
	print("Bought:", item_name)

func _on_health_potion_btn_pressed():
	buy_potion("Health Potion", HEALTH_PRICE)

func _on_strength_potion_btn_pressed():
	buy_potion("Strength Potion", STRENGTH_PRICE)

func _on_luck_potion_btn_pressed():
	buy_potion("Luck Potion", LUCK_PRICE)

func _on_close_btn_pressed():
	close_shop()
