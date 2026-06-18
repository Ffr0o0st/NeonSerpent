## EnemyManager — 敌人管理器
class_name EnemyManager extends Node

var _alive_enemies: Array = []  # Array[Node]
var _enemy_container: Node2D
var _snake_manager: Node = null  # SnakeManager


func _ready() -> void:
	var p = get_parent()
	if p and p.has_node("Enemies"):
		_enemy_container = p.get_node("Enemies") as Node2D
	else:
		_enemy_container = Node2D.new(); _enemy_container.name = "Enemies"
		if p: p.add_child(_enemy_container)
		else: add_child(_enemy_container)
	if p:
		_snake_manager = p.find_child("SnakeManager", true, false)


func _process(_delta: float) -> void:
	if get_tree().paused: return
	_check_body_crossings()
	_cleanup_dead_refs()
	# 更新全局缓存——炮台/子弹直接用 GameState.cached_enemies
	GameState.cached_enemies = _alive_enemies.duplicate()


## WaveManager 调用——立即生成敌人
func request_spawn(enemy_scene: PackedScene, grid_position: Vector2i) -> void:
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.position = GridUtils.cell_to_world(grid_position)
	_enemy_container.add_child(enemy)
	enemy.connect("died", _on_enemy_died)
	_alive_enemies.append(enemy)


func get_alive_count() -> int:
	_cleanup_dead_refs()
	return _alive_enemies.size()



## 敌人死亡——从列表移除（参数签名匹配 EnemyBase.died 信号）
func _on_enemy_died(_pos: Vector2, _food: int, _xp: int) -> void:
	# 找到并移除发送信号的敌人
	for i in range(_alive_enemies.size() - 1, -1, -1):
		if not is_instance_valid(_alive_enemies[i]):
			_alive_enemies.remove_at(i)


## 敌人穿过蛇身检测
func _check_body_crossings() -> void:
	if not _snake_manager: return
	var body_cells: Array = GameState.snake_body_cells  # Array[Vector2i]
	for enemy in _alive_enemies:
		if not is_instance_valid(enemy): continue
		var en = enemy as Node2D
		var enemy_cell = GridUtils.world_to_cell(en.position)
		for seg_idx in range(body_cells.size()):
			if body_cells[seg_idx] == enemy_cell:
				_snake_manager.mark_segment_disrupted(seg_idx)
				break


func _cleanup_dead_refs() -> void:
	var i = _alive_enemies.size() - 1
	while i >= 0:
		if not is_instance_valid(_alive_enemies[i]):
			_alive_enemies.remove_at(i)
		i -= 1
