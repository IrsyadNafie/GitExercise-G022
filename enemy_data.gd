extends Resource
class_name EnemyData

@export var is_static: bool = false
@export_group("Visuals")
@export var enemy_texture: Texture2D

@export_group("Core Stats")
@export var enemy_name: String = "Unknown"
@export var max_hp: int = 10
@export var max_sp: int = 5
@export var base_attack: int = 5

@export_group("Skills")
@export var special_skills: Array[Skill] = []
