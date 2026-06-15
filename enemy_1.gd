extends Actor

var available_skills: Array[Skill] = []

func _ready() -> void:
	super()
	is_player = false

func start_turn() -> void:
	super()

func setup_from_data(data: EnemyData) -> void:
	self.character_name = data.enemy_name
	self.max_hp = data.max_hp
	self.current_hp = data.max_hp
	self.max_sp = data.max_sp
	self.current_sp = data.max_sp
	self.base_attack = data.base_attack
	
	self.available_skills = data.special_skills
	self.skills = self.available_skills 
	
	self.is_player = false
	update_bars()
	
	if data.enemy_texture != null:
		var sprite = get_node_or_null("Sprite") 
		if sprite:
			sprite.texture = data.enemy_texture
