## GameState — 运行时游戏状态（Autoload 单例）
## 跨场景持久化当前运行数据。每个新游戏开始时调用 reset()。
extends Node

# === 关卡进度 ===

## 当前关卡索引（1-5）
var current_level: int = 1
## 当前波次索引（1-9）
var current_wave: int = 1
## 本关击杀总数
var kill_count: int = 0

# === 蛇身状态 ===

## 蛇身段数量（初始 3）
var snake_length: int = 3
## 蛇身段网格位置快照（Array[Vector2i]），由 SnakeManager 维护
var snake_body_cells: Array = []  # Array[Vector2i]

# === 核心状态 ===

## 核心当前血量
var core_hp: int = 200
## 核心最大血量
const CORE_MAX_HP: int = 200

# === 成长系统 ===

## 当前经验值
var current_xp: int = 0
## 已收集食物总数
var total_food_collected: int = 0
## 当前已激活的炮台槽位数量
var active_turret_slots: int = 1
## 已解锁的最大炮台槽位数量
var max_turret_slots: int = 1

# === 炮台与遗物 ===

## 已激活的炮台类型列表（Array[String]）
var turret_list: Array = []  # Array[String]
## 已拥有的遗物 ID 列表（Array[String]）
var relic_inventory: Array = []  # Array[String]

## 敌人缓存数组——EnemyManager 每帧更新，炮台/子弹直接读此数组避免 get_nodes_in_group
var cached_enemies: Array = []
## RelicManager 引用——由 RelicManager._ready() 设置，消除跨系统的 get_first_node_in_group 遍历
var relic_manager: Node = null
## CanvasLayer 引用——由 LevelBase 设置
var canvas_layer: CanvasLayer = null
## SnakeHead 引用——由 SnakeHead._ready() 设置
var snake_head: Node2D = null
## SnakeManager 引用——由 SnakeManager._ready() 设置
var snake_manager: Node = null

# === 计时与分数 ===

## 游戏已过时间（秒）
var elapsed_time: float = 0.0
## 总分
var score: int = 0

# === HP 倍率（根据关卡） ===

const LEVEL_HP_MULTIPLIERS: Array[float] = [1.0, 1.0, 1.25, 1.5, 1.75, 2.0]


## 获取当前关卡的 HP 倍率
func get_hp_multiplier() -> float:
	if current_level < LEVEL_HP_MULTIPLIERS.size():
		return LEVEL_HP_MULTIPLIERS[current_level]
	return 1.0


## 重置所有状态到默认值（新游戏开始）
func reset() -> void:
	current_level = 1
	current_wave = 1
	kill_count = 0
	snake_length = 3
	snake_body_cells.clear()
	core_hp = CORE_MAX_HP
	current_xp = 0
	total_food_collected = 0
	active_turret_slots = 1
	max_turret_slots = 1
	turret_list.clear()
	relic_inventory.clear()
	elapsed_time = 0.0
	score = 0
	cached_enemies.clear()
	relic_manager = null
	canvas_layer = null
	snake_head = null
	snake_manager = null


## 进入下一关
func advance_level() -> void:
	current_level += 1
	current_wave = 1


## 进入下一波
func advance_wave() -> void:
	current_wave += 1


## 增加蛇身段
func grow_snake(segments: int = 1) -> void:
	snake_length += segments
	_update_turret_slots()


## 根据蛇长更新最大炮台槽位（每 5 段解锁 1 槽位）
func _update_turret_slots() -> void:
	max_turret_slots = max(1, int(snake_length) / 5)
