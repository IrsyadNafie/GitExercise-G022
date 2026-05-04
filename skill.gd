extends Resource
class_name Skill

enum TargetType { SINGLE_ENEMY, ALL_ENEMY, SINGLE_ALLY, ALL_ALLY, SELF, RANDOM }

@export var name: String = "Skill Name"
@export var sp_cost: int = 5
@export var damage: int = 0
@export var heal_amount: int = 0
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var hits: int = 1
