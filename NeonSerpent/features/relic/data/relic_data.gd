## RelicData — 遗物/Buff 定义资源
class_name RelicData extends Resource

@export var relic_name: String = "Relic"
@export var description: String = ""
## 效果类型：damage / fire_rate / range / speed / magnet / heal
@export var effect_type: String = "damage"
## 效果数值（倍率或加值）
@export var effect_value: float = 1.0
