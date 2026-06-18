## SnakeHead — 玩家蛇头实体
## 基于离散 tick 系统（4 tick/秒）在网格上移动。
## _body_cells[0] 始终是蛇头位置，[1..body_length] 是身体段。
## SnakeManager 通过 moved 信号同步蛇身段，创建视觉节点。
class_name SnakeHead extends Node2D

# === 信号 ===

## 蛇头移动到新格（参数：new_cell: Vector2i, body_cells: Array[Vector2i]）
signal moved(new_cell: Vector2i, body_cells: Array)
## 玩家死亡（撞到自己）
signal died()

# === 状态 ===

## 当前格坐标
var current_cell: Vector2i = Vector2i(0, 15)
## 当前移动方向
var current_direction: Vector2i = Vector2i.RIGHT
## 缓冲的下一个方向
var _next_direction: Vector2i = Vector2i.RIGHT
## tick 计时器累积值
var _tick_accumulator: float = 0.0
## 是否可移动
var can_move: bool = true

# === 配置 ===

## tick 间隔（秒），默认 0.25 = 4 tick/秒
var tick_interval: float = 0.25
## 蛇身总段数（由 SnakeManager 更新）
var body_length: int = 3

# === 内部 ===

## 蛇身段位置快照：_body_cells[0]=蛇头, [1..]=身体段
var _body_cells: Array[Vector2i] = []
## 输入缓冲
var _input_buffered: bool = false
var _buffered_direction: Vector2i = Vector2i.RIGHT
## SnakeManager 引用
var snake_manager: Node = null

var _sprite: Sprite2D = null


func _ready() -> void:
	if GridUtils.config:
		current_cell = GridUtils.config.snake_start_position
		current_direction = GridUtils.config.snake_start_direction
		_next_direction = current_direction
		body_length = GridUtils.config.snake_initial_length
		tick_interval = 1.0 / GridUtils.config.snake_tick_rate

	_sprite = $Sprite
	if _sprite.texture:
		var target: float = 40.0
		_sprite.scale = Vector2(target / _sprite.texture.get_size().x, target / _sprite.texture.get_size().x)

	# 注册到 GameState 消除树遍历
	GameState.snake_head = self

	# 应用速度遗物加成
	_apply_speed_bonus()
	# 初始朝向
	_update_sprite_rotation()
	# 初始化 _body_cells：[0]=蛇头, [1..]=身体段沿反方向排列
	_body_cells.append(current_cell)
	var back_dir = -current_direction
	for i in range(1, body_length + 1):
		var seg_cell = current_cell + back_dir * i
		if GridUtils.config and GridUtils.config.is_within_bounds(seg_cell):
			_body_cells.append(seg_cell)
		else:
			_body_cells.append(current_cell + back_dir)

	_update_visual_position()


func _input(event: InputEvent) -> void:
	if not can_move or get_tree().paused:
		return

	var pressed_dir = _get_input_direction(event)
	if pressed_dir == Vector2i.ZERO or pressed_dir == current_direction:
		return
	# 禁止 180° 反转
	if pressed_dir == -current_direction:
		return

	_buffered_direction = pressed_dir
	_input_buffered = true

	# 输入发生在 tick 早期 → 立即应用（优化手感）
	if _tick_accumulator < tick_interval * 0.1:
		_next_direction = pressed_dir
		_input_buffered = false


## 从 InputEvent 中读取方向
func _get_input_direction(event: InputEvent) -> Vector2i:
	if not event.is_pressed():
		return Vector2i.ZERO
	if event.is_action(&"move_up") or event.is_action(&"ui_up"):
		return Vector2i.UP
	if event.is_action(&"move_down") or event.is_action(&"ui_down"):
		return Vector2i.DOWN
	if event.is_action(&"move_left") or event.is_action(&"ui_left"):
		return Vector2i.LEFT
	if event.is_action(&"move_right") or event.is_action(&"ui_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


## 执行一次 tick 移动
func _execute_tick() -> void:
	current_direction = _next_direction
	var next_cell = current_cell + current_direction

	# 边界检测——碰到边界则本 tick 不移动
	if not GridUtils.config or not GridUtils.config.is_within_bounds(next_cell):
		return

	# 自碰检测——从第 2 段开始查（跳过 index 0=头, index 1=刚离开的颈部）
	for i in range(2, _body_cells.size()):
		if _body_cells[i] == next_cell:
			died.emit()
			EventBus.player_died.emit()
			return

	# 移动：头部推进，尾部收缩
	current_cell = next_cell
	_body_cells.push_front(current_cell)
	while _body_cells.size() > body_length + 1:  # +1 因为 [0]=头
		_body_cells.pop_back()

	_update_visual_position()
	_update_sprite_rotation()
	moved.emit(current_cell, _body_cells.duplicate())


## 更新世界坐标
func _update_visual_position() -> void:
	if GridUtils.config:
		position = GridUtils.cell_to_world(current_cell)




func _apply_speed_bonus() -> void:
	var rm = GameState.relic_manager
	if rm and rm.has_method("get_speed_mult"):
		var sm: float = rm.call("get_speed_mult")
		tick_interval = (1.0 / GridUtils.config.snake_tick_rate) / sm


func set_can_move(enable: bool) -> void:
	can_move = enable


func _update_sprite_rotation() -> void:
	match current_direction:
		Vector2i.RIGHT: _sprite.rotation = PI
		Vector2i.UP:    _sprite.rotation = PI / 2.0
		Vector2i.LEFT:  _sprite.rotation = 0.0
		Vector2i.DOWN:  _sprite.rotation = -PI / 2.0
		_:              _sprite.rotation = PI


func _process(delta: float) -> void:
	if not can_move or get_tree().paused:
		return

	_tick_accumulator += delta
	if _tick_accumulator >= tick_interval:
		_tick_accumulator -= tick_interval
		if _input_buffered and _buffered_direction != -current_direction:
			_next_direction = _buffered_direction
			_input_buffered = false
		_execute_tick()
