extends Area2D

var player_near = false

func _ready():
	$Label.text = ""

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		var shop = get_tree().current_scene.get_node_or_null("UI/ShopUI")

		if shop:
			print("Opening Shop")
			shop.visible = true
		else:
			print("ERROR: ShopUI not found! Check node path")

func _on_body_entered(body):
	print("Entered:", body.name)

	if body.name == "Player":
		player_near = true
		$Label.text = "Press E to Shop"

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$Label.text = ""
