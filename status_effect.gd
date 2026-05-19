extends Resource
class_name StatusEffect

enum EffectType { FIRE, STUN, ENCHANT }

@export var icon: Texture2D
@export var name: String = "Burn"
@export var type: EffectType = EffectType.FIRE
@export var amount: int = 2
@export var duration: int = 3
@export var is_permanent: bool = false
