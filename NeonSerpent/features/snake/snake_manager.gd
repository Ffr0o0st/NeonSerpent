## SnakeManager — 蛇身管理器
## 炮台=身体段（每3段一个：3,6,9...），段自己负责射击。
class_name SnakeManager extends Node

## 即将长出一个炮台段，需要玩家选择类型
signal turret_growth_ready(segment_index: int)

@export var snake_head: SnakeHead
var disruption_timers: Dictionary = {}
@export var disruption_duration: float = 5.0

var _body_segment_scene: PackedScene = preload("res://features/snake/snake_body_segment.tscn")
var _segment_nodes: Array = []  # Array[SnakeBodySegment]
var _body_container: Node2D
var _segments_per_slot: int = 3
var _last_known_body_length: int = 0
var _food_counter: int = 0
## 等待炮台类型选择（挂起增长）
var _pending_turret_growth: bool = false
var _projectile_parent: Node2D = null


func _ready() -> void:
	if not snake_head:
		var p = get_parent()
		if p and p.has_node("SnakeHead"): snake_head = p.get_node("SnakeHead") as SnakeHead
		if not snake_head: push_error("[SnakeManager] 缺少 SnakeHead 引用！"); return

	if get_parent() and get_parent().has_node("SnakeBody"):
		_body_container = get_parent().get_node("SnakeBody") as Node2D
	else:
		_body_container = Node2D.new(); _body_container.name = "SnakeBody"
		get_parent().add_child(_body_container)

	# 确保 Projectiles 容器存在
	if get_parent() and get_parent().has_node("Projectiles"):
		_projectile_parent = get_parent().get_node("Projectiles") as Node2D

	if GridUtils.config:
		_segments_per_slot = GridUtils.config.segments_per_turret_slot
		disruption_duration = GridUtils.config.disruption_duration

	snake_head.moved.connect(_on_head_moved)
	GameState.snake_manager = self
	EventBus.food_collected.connect(_on_food_collected)

	_last_known_body_length = snake_head.body_length
	_spawn_body_segments()
	_sync_game_state()


func _process(delta: float) -> void:
	if get_tree().paused: return
	_update_disruption_timers(delta)


## 蛇头移动 → 同步段节点位置
func _on_head_moved(_new_cell: Vector2i, body_cells: Array) -> void:
	var body_only = _extract_body_cells(body_cells)
	for i in range(min(_segment_nodes.size(), body_only.size())):
		_segment_nodes[i].position = GridUtils.cell_to_world(body_only[i])
		_segment_nodes[i].set_cell(body_only[i])
	if snake_head.body_length != _last_known_body_length:
		_last_known_body_length = snake_head.body_length
		_sync_segment_nodes()
	_sync_game_state()


## 食物收集 → 增长判定
func _on_food_collected(_amount: int) -> void:
	if _pending_turret_growth: return  # 正在等待炮台选择
	_food_counter += 1
	var cost: int = _get_growth_cost()
	if _food_counter >= cost:
		_food_counter -= cost
		_check_turret_growth()


## 检查新段是否是炮台位置
func _check_turret_growth() -> void:
	var next_len: int = snake_head.body_length + 1
	if next_len % _segments_per_slot == 0:
		# 这是炮台段！暂停游戏，弹出升级面板
		_pending_turret_growth = true
		get_tree().paused = true
		turret_growth_ready.emit(next_len)
	else:
		# 普通段，直接增长
		_do_grow(false, "")


## 由 UpgradeManager 调用：玩家选择了炮台类型
func grow_turret_segment(turret_type: String) -> void:
	_pending_turret_growth = false
	get_tree().paused = false
	_do_grow(true, turret_type)


## 实际执行增长
func _do_grow(is_turret: bool, turret_type: String) -> void:
	snake_head.body_length += 1
	_last_known_body_length = snake_head.body_length
	# 添加新段节点
	var seg = _body_segment_scene.instantiate()
	seg.name = "Segment%03d" % _segment_nodes.size()
	if is_turret:
		seg.set("is_turret", true)
		seg.set("turret_type", turret_type)
		seg.call("set_projectile_parent", _projectile_parent)
	_body_container.add_child(seg)
	_segment_nodes.append(seg)
	_sync_game_state()


## 段被敌人穿过 → 瘫痪
func mark_segment_disrupted(segment_index: int) -> void:
	if segment_index < 0 or segment_index >= _segment_nodes.size(): return
	disruption_timers[segment_index] = disruption_duration
	_segment_nodes[segment_index].set_disrupted(true)


func is_segment_disrupted(segment_index: int) -> bool:
	return disruption_timers.get(segment_index, 0.0) > 0.0


# === 内部 ===

func _extract_body_cells(all_cells: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for i in range(1, all_cells.size()): result.append(all_cells[i] as Vector2i)
	return result


func _spawn_body_segments() -> void:
	for i in range(snake_head.body_length):
		var seg = _body_segment_scene.instantiate()
		seg.name = "Segment%03d" % i
		_body_container.add_child(seg)
		_segment_nodes.append(seg)


func _sync_segment_nodes() -> void:
	var target: int = snake_head.body_length
	while _segment_nodes.size() > target:
		var extra = _segment_nodes.pop_back()
		if extra and is_instance_valid(extra): extra.queue_free()
	# 注意：新增段由 _do_grow 处理，这里只处理缩减


func _update_disruption_timers(delta: float) -> void:
	var restored: Array[int] = []
	for seg_idx in disruption_timers.keys():
		disruption_timers[seg_idx] -= delta
		if disruption_timers[seg_idx] <= 0.0: restored.append(seg_idx)
	for seg_idx in restored:
		disruption_timers.erase(seg_idx)
		if seg_idx < _segment_nodes.size(): _segment_nodes[seg_idx].set_disrupted(false)


func _sync_game_state() -> void:
	GameState.snake_length = snake_head.body_length
	var all: Array[Vector2i] = []
	for seg in _segment_nodes:
		if seg and is_instance_valid(seg): all.append(seg.get("grid_cell"))
	GameState.snake_body_cells = all


func _get_growth_cost() -> int:
	var bl: int = snake_head.body_length
	if bl <= 8: return 3
	elif bl <= 16: return 4
	elif bl <= 24: return 5
	elif bl <= 30: return 6
	else: return 7
