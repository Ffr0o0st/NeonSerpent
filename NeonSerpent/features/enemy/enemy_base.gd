## EnemyBase — 所有敌人的基类
## 在连续空间中移动，用 _draw() 绘制形状。
## 子类可覆盖 _ai_steering() 来定制 AI 行为。
class_name EnemyBase extends Node2D

# === 信号 ===

signal died(position: Vector2, food_count: int, xp: int)

# === 数据 ===

@export var enemy_data: EnemyData
@export var texture: Texture2D = null

## 当前血量（按关卡 HP 倍率缩放后的实际值）
var current_hp: float = 100.0

## 移动速度
var speed: float = 1.0

# === 内部 ===

var _sprite: Sprite2D = null
var _has_sprite: bool = false
var _core_position: Vector2 = Vector2.ZERO
var _snake_head_ref: SnakeHead


## 绘制颜色（由 _ready 从 enemy_data 设置）
var draw_color: Color = Color.WHITE

func _ready() -> void:
	_sprite = $Sprite
	if _sprite.texture:
		_sprite.show()
		_has_sprite = true
	else:
		_sprite.hide()

	add_to_group(&"enemy")  # 供炮台瞄准系统查找
	if enemy_data:
		speed = enemy_data.move_speed * GridUtils.config.cell_size  # 转换为像素/秒
		current_hp = enemy_data.base_hp * GameState.get_hp_multiplier()
			# 移速标准化：按生成位置与核心距离等比缩放
		# 角落（最远）= 全速，边中点（最近）= ~70% 速，统一到达时间
		if GridUtils.config:
			var core_w: Vector2 = GridUtils.cell_to_world(GridUtils.config.core_position)
			var sd: float = position.distance_to(core_w)
			var hw: float = GridUtils.config.grid_width / 2.0
			var hh: float = GridUtils.config.grid_height / 2.0
			var md: float = sqrt(hw * hw + hh * hh) * GridUtils.config.cell_size
			if md > 0: speed *= sd / md
	draw_color = enemy_data.color if enemy_data else Color.WHITE
	# 注意：_original_speed 不在此设——子类 _ready() 可能在此之后才设 speed。
	# 由 apply_slow() 首次调用时捕获当前 speed 作为基准。

	# 核心位置
	if GridUtils.config:
		_core_position = GridUtils.cell_to_world(GridUtils.config.core_position)

	# 蛇头引用（用于 AI 类型 chase_snake）
	_snake_head_ref = GameState.snake_head as SnakeHead


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			speed = _original_speed
			modulate = Color(1, 1, 1, 1)

	var dir = _ai_steering()
	position += dir * speed * delta

	# 检查是否到达核心
	if position.distance_to(_core_position) < GridUtils.config.cell_size * 0.5:
		# 进入核心区域，由 Core 的 Area2D 处理伤害
		pass

	queue_redraw()


## AI 操控方向（子类可覆盖）
func _ai_steering() -> Vector2:
	match enemy_data.ai_type if enemy_data else "straight_to_core":
		"straight_to_core":
			return _steer_to_core()
		"chase_snake":
			return _steer_to_snake()
		"mixed":
			var to_core = _steer_to_core()
			var to_snake = _steer_to_snake()
			return (to_core * enemy_data.core_weight + to_snake * (1.0 - enemy_data.core_weight)).normalized()
		_:
			return _steer_to_core()


func _steer_to_core() -> Vector2:
	return (_core_position - position).normalized()


func _steer_to_snake() -> Vector2:
	if _snake_head_ref:
		return (_snake_head_ref.position - position).normalized()
	return _steer_to_core()


func take_damage(amount: float) -> void:
	current_hp -= amount
	# 受击闪白（使用 tree tween，防止节点被 queue_free 时 tween 随节点销毁）
	var pre_flash: Color = modulate
	modulate = Color(5, 5, 5, 1)  # 过曝白闪，GL modulate>1 产生 bloom
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate", pre_flash, 0.12)
	if current_hp <= 0:
		_die()


var _original_speed: float = -1.0  # 记录原始速度用于减速恢复
var _slow_timer: float = 0.0

func apply_slow(amount: float, duration: float) -> void:
	if _original_speed < 0: _original_speed = speed
	speed = _original_speed * (1.0 - amount)  # 原始速度 ×70%
	_slow_timer = duration
	modulate = Color(0.6, 0.6, 1.0)  # 蓝调视觉反馈


## 接受增幅光环（巨兽每 8s 对周围敌人 +15% 移速）
func apply_boost(amount: float) -> void:
	speed *= (1.0 + amount)

func get_core_damage() -> int:
	return int(enemy_data.core_damage) if enemy_data else 1


func _die() -> void:
	var food = enemy_data.food_drop_count if enemy_data else 1
	var xp = enemy_data.xp_reward if enemy_data else 5
	died.emit(position, food, xp)
	EventBus.enemy_killed.emit(enemy_data.display_name if enemy_data else "", position, food)
	queue_free()


## 绘制敌人形状（子类可覆盖）
func _draw() -> void:
	if _has_sprite: return
	var s: float = enemy_data.visual_size / 2.0 if enemy_data else 16.0
	var c: Color = draw_color
	match enemy_data.shape if enemy_data else "diamond":
		"diamond":
			_draw_diamond(s, c)
		"triangle":
			_draw_triangle(s, c)
		"square":
			draw_rect(Rect2(-s, -s, s * 2, s * 2), c)
		"circle":
			draw_circle(Vector2.ZERO, s, c)
		_:
			_draw_diamond(s, c)
	# 外发光
	draw_circle(Vector2.ZERO, s * 1.2, Color(c, 0.2))


func _draw_diamond(size: float, c: Color) -> void:
	var points = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0),
	])
	draw_polygon(points, PackedColorArray([c, c, c, c]))
	draw_polyline(points + PackedVector2Array([Vector2(0, -size)]), Color(c, 0.6), 1.0)


func _draw_triangle(size: float, c: Color) -> void:
	# 三角指向移动方向的上方
	var points = PackedVector2Array([
		Vector2(0, -size),
		Vector2(-size * 0.75, size * 0.66),
		Vector2(size * 0.75, size * 0.66),
	])
	draw_polygon(points, PackedColorArray([c, c, c]))
	draw_polyline(points + PackedVector2Array([Vector2(0, -size)]), Color(c, 0.6), 1.0)
