## RelicManager — 遗物效果管理（21 种遗物）
class_name RelicManager extends Node

var active_relics: Array = []
func _ready() -> void:
	GameState.relic_manager = self

# 通用 Buff
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var range_bonus: int = 0
var speed_mult: float = 1.0
var magnet_bonus: float = 0.0
var heal_bonus: int = 0

# 进化 Buff（按炮台类型）
var evo_turrets: Dictionary = {}  # "machinegun" → 倍率

# 融合标记
var fusion_unlocked: Dictionary = {}  # "fusion_mg_ice" → true

# 蛇身 Buff
var body_elastic_skip: int = 0  # 额外跳过的自碰检测段数
var body_growth_reduction: int = 0  # 成长成本 -N
var body_armor_reduction: float = 0.0  # 瘫痪时间减少
var body_longer_start: int = 0  # 初始蛇长 +N（仅下一关生效）

# 特殊 Buff
var overheat_kill_threshold: int = 0
var core_shield_charges: int = 0
var double_food_chance: float = 0.0


func add_relic(relic: Resource) -> void:
	active_relics.append(relic)
	var etype: String = relic.get("effect_type")
	var val: float = relic.get("effect_value")
	match etype:
		"damage":   damage_mult += val
		"fire_rate": fire_rate_mult -= val
		"range":    range_bonus += int(val)
		"speed":    speed_mult += val
		"magnet":   magnet_bonus += val
		"heal":     heal_bonus += int(val)
		# 进化类
		"evo_machinegun", "evo_mortar", "evo_laser", "evo_ice", "evo_flame", "evo_lightning":
			var turret_key: String = etype.trim_prefix("evo_")
			evo_turrets[turret_key] = evo_turrets.get(turret_key, 1.0) + (val - 1.0)
		# 融合类
		"fusion_mg_ice", "fusion_mortar_flame", "fusion_laser_lightning":
			fusion_unlocked[etype] = true
		# 蛇身类
		"body_elastic": body_elastic_skip = int(val)
		"body_growth":  body_growth_reduction = int(val)
		"body_armor":   body_armor_reduction += val  # 负值 = 减少瘫痪时间
		"body_longer":  body_longer_start = int(val)
		# 特殊类
		"special_overheat": overheat_kill_threshold = 15
		"special_shield":   core_shield_charges += 1
		"special_double_food": double_food_chance += val


func get_damage_mult() -> float: return damage_mult
func get_fire_interval_mult() -> float: return max(fire_rate_mult, 0.1)
func get_range_bonus() -> int: return range_bonus
func get_speed_mult() -> float: return speed_mult
func get_magnet_bonus() -> float: return magnet_bonus
func get_heal_bonus() -> int: return heal_bonus
func get_evo_mult(turret_type: String) -> float: return evo_turrets.get(turret_type, 1.0)
func has_fusion(key: String) -> bool: return fusion_unlocked.get(key, false)
func get_body_elastic_skip() -> int: return body_elastic_skip
func get_body_growth_reduction() -> int: return body_growth_reduction
func get_body_armor_reduction() -> float: return body_armor_reduction
func get_body_longer_start() -> int: return body_longer_start
func get_overheat_threshold() -> int: return overheat_kill_threshold
func has_core_shield() -> bool:
	if core_shield_charges > 0: core_shield_charges -= 1; return true
	return false
func get_double_food_chance() -> float: return double_food_chance
