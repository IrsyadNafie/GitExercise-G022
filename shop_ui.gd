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

func _on_health_btn_pressed():
	selected_items["Health"] += 1
	update_ui()

func _on_strength_btn_pressed():
	selected_items["Strength"] += 1
	update_ui()

func update_ui():
	$Panel/QuantityLabel.text = "H:" + str(selected_items["Health"]) + " S:" + str(selected_items["Strength"])

	var total = selected_items["Health"] * health_price + selected_items["Strength"] * strength_price
	$Panel/TotalCost.text = "Total: " + str(total)

func _on_confirm_btn_pressed():
	var total = selected_items["Health"] * health_price + selected_items["Strength"] * strength_price

	if GameManager.coins >= total:
		GameManager.coins -= total
		print("Purchase Successful")

		# FOR NOW just print
		print(selected_items)

		# reset
		selected_items["Health"] = 0
		selected_items["Strength"] = 0
		update_ui()
	else:
		print("Not enough money")

func _on_close_btn_pressed():
	visible = false
