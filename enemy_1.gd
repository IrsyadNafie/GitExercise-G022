extends Actor

func _ready() -> void:
	super()
	character_name = "Enemy1"
	is_player = false

func start_turn() -> void:
	super() 
	action_logged.emit(">" + character_name + " glares menacingly...")
	await get_tree().create_timer(1.5).timeout
	end_turn()
