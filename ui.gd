extends CanvasLayer

func _process(delta):
	$CoinLabel.text = "Coins: " + str(GameManager.coins)
