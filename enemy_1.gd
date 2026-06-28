extends Actor

var available_skills: Array[Skill] = []
var is_static: bool = false
var base_sprite_x: float = 0.0
var sway_timer: float = 0.0

func _ready() -> void:
	super()
	is_player = false
	await get_tree().process_frame
	var sprite = get_node_or_null("Sprite")
	if sprite:
		base_sprite_x = sprite.position.x

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
	is_static = data.is_static
	update_bars()
	
	if data.enemy_texture != null:
		var sprite = get_node_or_null("Sprite") 
		if sprite:
			sprite.texture = data.enemy_texture

func _process(delta: float) -> void:
	if is_static:
		return
		
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sway_timer += delta
		var step = int(sway_timer * 1.0) % 2
		if step == 0:
			sprite.position.x = base_sprite_x - 2
		else:
			sprite.position.x = base_sprite_x + 2
