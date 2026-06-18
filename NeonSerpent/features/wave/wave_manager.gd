## WaveManager — 波次管理器（关卡级）
class_name WaveManager extends Node

signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal level_completed()

enum Phase { PRE_GAME, COUNTDOWN, WAVE_ACTIVE, WAVE_CLEARED, LEVEL_CLEARED }
var current_phase: Phase = Phase.PRE_GAME
var current_wave_index: int = -1

@export var level_data = null  # LevelData Resource
var _enemy_manager = null  # EnemyManager
var _spawn_tasks: Array[Dictionary] = []  # [{scene, interval, remaining, timer}]
var _all_spawned: bool = false
var _transition_timer: float = 0.0
var _timeout_timer: float = 0.0

const COUNTDOWN: float = 3.0
const TRANSITION: float = 2.0


func _ready() -> void:
	var p: Node = get_parent()
	if p:
		_enemy_manager = p.find_child("EnemyManager", true, false) as EnemyManager


func _process(delta: float) -> void:
	if get_tree().paused: return
	match current_phase:
		Phase.COUNTDOWN:
			_transition_timer -= delta
			if _transition_timer <= 0: _start_wave()
		Phase.WAVE_ACTIVE:
			_process_spawn(delta)
			_timeout_timer -= delta
			if _all_spawned and _timeout_timer <= 0: _clear_wave()
			if _all_spawned and (_enemy_manager == null or _enemy_manager.get_alive_count() <= 0): _clear_wave()
		Phase.WAVE_CLEARED:
			_transition_timer -= delta
			if _transition_timer <= 0: _next_wave()


func start_game() -> void:
	current_wave_index = -1
	_next_wave()


func _next_wave() -> void:
	current_wave_index += 1
	if not level_data or current_wave_index >= level_data.waves.size():
		current_phase = Phase.LEVEL_CLEARED
		EventBus.level_completed.emit(GameState.current_level)
		level_completed.emit()
		return

	current_phase = Phase.COUNTDOWN
	_transition_timer = COUNTDOWN
	GameState.current_wave = current_wave_index + 1
	EventBus.wave_started.emit(current_wave_index + 1)


func _start_wave() -> void:
	current_phase = Phase.WAVE_ACTIVE
	_all_spawned = false
	var wave: Resource = level_data.waves[current_wave_index]
	_timeout_timer = wave.duration_estimate * 2.0

	_spawn_tasks.clear()
	for i in range(wave.enemy_scene_paths.size()):
		if i >= wave.enemy_counts.size(): break
		var count: int = wave.enemy_counts[i] if i < wave.enemy_counts.size() else 0
		var interval: float = wave.spawn_intervals[i] if i < wave.spawn_intervals.size() else 2.0
		var delay: float = wave.start_delays[i] if i < wave.start_delays.size() else 0.0
		var scene: PackedScene = load(wave.enemy_scene_paths[i]) if wave.enemy_scene_paths[i] else null
		_spawn_tasks.append({scene=scene, interval=interval, delay=delay, remaining=count})


func _process_spawn(delta: float) -> void:
	if _all_spawned: return
	var any_left: bool = false
	for task in _spawn_tasks:
		if task.remaining <= 0: continue
		any_left = true
		task.delay -= delta
		if task.delay <= 0:
			task.delay = task.interval
			task.remaining -= 1
			_spawn_one(task.scene)
	_all_spawned = not any_left


func _spawn_one(scene: PackedScene) -> void:
	if not scene or not _enemy_manager: return
	var cell: Vector2i = _random_edge_cell()
	_enemy_manager.request_spawn(scene, cell)


func _random_edge_cell() -> Vector2i:
	var gw: int = GridUtils.config.grid_width
	var gh: int = GridUtils.config.grid_height
	match randi() % 4:
		0: return Vector2i(randi() % gw, 0)
		1: return Vector2i(randi() % gw, gh - 1)
		2: return Vector2i(0, randi() % gh)
		_: return Vector2i(gw - 1, randi() % gh)


func _clear_wave() -> void:
	current_phase = Phase.WAVE_CLEARED
	_transition_timer = TRANSITION
	EventBus.wave_cleared.emit(current_wave_index + 1)


func _on_enemy_killed(_t: String, _p: Vector2, _f: int) -> void:
	pass
