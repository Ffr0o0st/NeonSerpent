## GameFlowManager — 游戏流程状态机
class_name GameFlowManager extends Node

enum State { PRE_GAME, PLAYING, LEVEL_CLEAR, RELIC_SELECTION, GAME_OVER, VICTORY }
var current_state: State = State.PRE_GAME

var _snake_head: Node2D = null
var _core: Node2D = null
var _wave_manager: Node = null
var _canvas_layer: CanvasLayer = null
var _game_over_panel: Control = null
var _victory_panel: Control = null
var _pause_panel: Control = null
var _relic_panel: Control = null
var _relic_manager: Node = null
var _level_data_list: Array = []
var _current_level_index: int = 0
var _pending_next_level: bool = false


func _ready() -> void:
	var p: Node = get_parent()
	if p:
		_snake_head = p.find_child("SnakeHead", true, false) as Node2D
		_core = p.find_child("Core", true, false) as Node2D
		_wave_manager = p.find_child("WaveManager", true, false)
		_relic_manager = p.find_child("RelicManager", true, false)

	_canvas_layer = GameState.canvas_layer
	EventBus.player_died.connect(_on_player_died)
	EventBus.core_destroyed.connect(_on_core_destroyed)
	if _wave_manager and _wave_manager.has_signal("level_completed"):
		_wave_manager.level_completed.connect(_on_level_completed)

	_load_level_data()
	_create_ui_panels()


func _load_level_data() -> void:
	var paths: Array[String] = [
		"res://features/wave/data/level_01_data.tres",
		"res://features/wave/data/level_02_data.tres",
		"res://features/wave/data/level_03_data.tres",
		"res://features/wave/data/level_04_data.tres",
		"res://features/wave/data/level_05_data.tres",
	]
	for path in paths:
		var res: Resource = load(path)
		if res: _level_data_list.append(res)


func start_current_level() -> void:
	current_state = State.PLAYING
	_configure_level()


func _configure_level() -> void:
	if _current_level_index >= _level_data_list.size(): return
	var ld: Resource = _level_data_list[_current_level_index]
	if _wave_manager and ld:
		_wave_manager.set("level_data", ld)
		GameState.current_level = _current_level_index + 1
		GameState.current_wave = 1
		_wave_manager.call("start_game")


## === 关卡完成 → 显示遗物面板 ===

func _on_level_completed() -> void:
	if current_state != State.PLAYING: return
	current_state = State.LEVEL_CLEAR

	# 核心回血
	if _core and _core.has_method("heal"):
		var heal_amount: int = GridUtils.config.core_heal_per_level if GridUtils.config else 40
		if _relic_manager and _relic_manager.has_method("get_heal_bonus"):
			heal_amount += _relic_manager.call("get_heal_bonus")
		_core.call("heal", heal_amount)

	# 推进关卡索引
	_current_level_index += 1
	if _current_level_index >= _level_data_list.size():
		current_state = State.VICTORY
		_show_victory()
		return

	# 显示遗物选择面板
	current_state = State.RELIC_SELECTION
	get_tree().paused = true
	if _relic_panel:
		_relic_panel.call("generate_options")
		_relic_panel.show()


func _on_relic_selected(relic: Resource) -> void:
	if _relic_manager and _relic_manager.has_method("add_relic"):
		_relic_manager.call("add_relic", relic)
	# 继续到下一关
	current_state = State.PLAYING
	_configure_level()


## === 死亡/GameOver ===

func _on_player_died() -> void:
	if current_state != State.PLAYING: return
	current_state = State.GAME_OVER
	if _snake_head and _snake_head.has_method("set_can_move"):
		_snake_head.set("can_move", false)
	_show_game_over("你撞到了自己！")


func _on_core_destroyed() -> void:
	if current_state != State.PLAYING: return
	current_state = State.GAME_OVER
	if _snake_head and _snake_head.has_method("set_can_move"):
		_snake_head.set("can_move", false)
	_show_game_over("核心被摧毁！")


## === UI 面板 ===

func _create_ui_panels() -> void:
	if not _canvas_layer: return
	# GameOver
	var go_scene: PackedScene = load("res://ui/menus/game_over.tscn") as PackedScene
	if go_scene:
		_game_over_panel = go_scene.instantiate() as Control
		_canvas_layer.add_child(_game_over_panel)
		_game_over_panel.hide()
		if _game_over_panel.has_signal("restart"):
			_game_over_panel.restart.connect(_restart_game)
	# Victory
	var v_scene: PackedScene = load("res://ui/menus/victory_screen.tscn") as PackedScene
	if v_scene:
		_victory_panel = v_scene.instantiate() as Control
		_canvas_layer.add_child(_victory_panel)
		_victory_panel.hide()
		if _victory_panel.has_signal("restart"):
			_victory_panel.restart.connect(_restart_game)
	# Pause
	var p_scene: PackedScene = load("res://ui/menus/pause_menu.tscn") as PackedScene
	if p_scene:
		_pause_panel = p_scene.instantiate() as Control
		_canvas_layer.add_child(_pause_panel)
		_pause_panel.hide()
	# Relic
	var r_scene: PackedScene = load("res://features/relic/relic_panel.tscn") as PackedScene
	if r_scene:
		_relic_panel = r_scene.instantiate() as Control
		_canvas_layer.add_child(_relic_panel)
		_relic_panel.hide()
		if _relic_panel.has_signal("relic_selected"):
			_relic_panel.relic_selected.connect(_on_relic_selected)

	EventBus.game_paused.connect(_show_pause)
	EventBus.game_resumed.connect(_hide_pause)


func _show_game_over(reason: String) -> void:
	if _game_over_panel:
		_game_over_panel.call("set_reason", reason)
		_game_over_panel.show()
	get_tree().paused = true


func _show_victory() -> void:
	if _victory_panel: _victory_panel.show()
	get_tree().paused = true


func _show_pause() -> void:
	if _pause_panel: _pause_panel.show()


func _hide_pause() -> void:
	if _pause_panel: _pause_panel.hide()


func _restart_game() -> void:
	get_tree().paused = false
	GameState.reset()
	get_tree().reload_current_scene()
