## LevelData — 单个关卡配置资源
class_name LevelData extends Resource

@export var level_name: String = "Level 1"
@export var hp_multiplier: float = 1.0
@export var waves: Array[WaveData] = []
@export var relic_count: int = 0
@export var starting_snake_length: int = 3
@export var starting_turret: String = "machinegun"
