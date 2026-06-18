## EnemyData — 敌人类型数据资源
## 每种敌人一个 .tres 文件，Inspector 中可编辑所有数值。
class_name EnemyData extends Resource

## 显示名称
@export var display_name: String = "Enemy"

## 基础血量（随关卡 HP 倍率缩放）
@export var base_hp: float = 100.0

## 移动速度（格/秒）
@export var move_speed: float = 1.0

## 对核心的单次伤害（每 damage_cooldown 秒造成一次）
@export var core_damage: float = 1.0

## 击杀后掉落食物数量
@export var food_drop_count: int = 1

## 击杀经验值
@export var xp_reward: int = 5

## 视觉颜色
@export var color: Color = Color.WHITE

## 视觉形状："diamond" / "triangle" / "square" / "circle"
@export var shape: String = "diamond"

## 视觉尺寸（像素）
@export var visual_size: float = 32.0

## AI 类型："straight_to_core" / "chase_snake" / "mirror_player" / "mixed"
@export var ai_type: String = "straight_to_core"

## 混合 AI 时向核心的权重（0-1）
@export var core_weight: float = 1.0

## 特殊能力标志
@export var has_shield: bool = false
@export var shield_duration: float = 2.0
@export var shield_cooldown: float = 6.0
@export var explode_on_death: bool = false
@export var explode_radius: float = 3.0
@export var has_aura: bool = false
@export var aura_buff_percent: float = 0.15
@export var aura_cooldown: float = 8.0
