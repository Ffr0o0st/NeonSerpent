## LevelBase — 基础关卡场景脚本
class_name LevelBase extends Node2D

@export var level_data: Resource
@export var grid_config: GridConfig:
	set(v):
		grid_config = v
		if v and GridUtils:
			GridUtils.setup(v)

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var game_world: Node2D = $GameWorld
@onready var snake_head: SnakeHead = $GameWorld/SnakeHead
@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	add_to_group(&"level_base")

	if grid_config:
		GridUtils.setup(grid_config)
	else:
		push_error("[LevelBase] GridConfig 缺失！")

	_setup_glow()
	_setup_hud()
	_setup_wave_manager()
	_setup_vfx()
	_setup_relic_manager()
	_setup_turret_manager()
	_setup_upgrade_manager()
	_setup_game_flow_manager()


func _setup_relic_manager() -> void:
	var rm_script = load("res://features/relic/relic_manager.gd") as Script
	var rm = Node.new()
	rm.set_script(rm_script)
	rm.name = "RelicManager"
	game_world.add_child(rm)


func _setup_game_flow_manager() -> void:
	var gf_script = load("res://common/game_flow_manager.gd") as Script
	var gf = Node.new()
	gf.set_script(gf_script)
	gf.name = "GameFlowManager"
	game_world.add_child(gf)
	# 延迟一帧启动（等所有 Manager 初始化完成）
	gf.call_deferred("start_current_level")


func _setup_vfx() -> void:
	# 死亡粒子
	var dp_scene = load("res://features/vfx/death_particles.tscn") as PackedScene
	var dp = dp_scene.instantiate()
	dp.name = "DeathParticles"
	game_world.add_child(dp)
	# 波次清除大字 → CanvasLayer
	var wct_scene = load("res://features/vfx/wave_clear_text.tscn") as PackedScene
	var wct = wct_scene.instantiate()
	wct.name = "WaveClearText"
	canvas_layer.add_child(wct)


func _setup_glow() -> void:
	if not world_environment: return
	var env = world_environment.environment
	if not env:
		env = Environment.new()
		world_environment.environment = env
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0A0A14")
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE


func _setup_hud() -> void:
	var hud_scene = load("res://ui/hud/game_hud.tscn") as PackedScene
	if hud_scene:
		var hud = hud_scene.instantiate()
		canvas_layer.add_child(hud)
	GameState.canvas_layer = canvas_layer


func _setup_wave_manager() -> void:
	var wm = game_world.find_child("WaveManager", true, false) as WaveManager
	if wm and not wm.level_data:
		# 加载第 1 关数据作为默认（启动由 GameFlowManager 统一管理）
		var ld = load("res://features/wave/data/level_01_data.tres") as LevelData
		if ld:
			wm.level_data = ld
			GameState.current_level = 1


func _setup_turret_manager() -> void:
	# 确保 Turrets 容器存在
	if not game_world.has_node("Turrets"):
		var turrets = Node2D.new(); turrets.name = "Turrets"
		game_world.add_child(turrets)
	# 确保 Projectiles 容器存在
	if not game_world.has_node("Projectiles"):
		var proj = Node2D.new(); proj.name = "Projectiles"
		game_world.add_child(proj)
	# 创建 TurretManager（用 load 避免 class_name 加载顺序问题）
	var tm_script = load("res://features/turret/turret_manager.gd") as Script
	var tm = Node.new()
	tm.set_script(tm_script)
	tm.name = "TurretManager"
	game_world.add_child(tm)


func _setup_upgrade_manager() -> void:
	var um_script = load("res://features/upgrade/upgrade_manager.gd") as Script
	var um = Node.new()
	um.set_script(um_script)
	um.name = "UpgradeManager"
	game_world.add_child(um)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause_game"):
		_toggle_pause()


func _toggle_pause() -> void:
	var paused = get_tree().paused
	get_tree().paused = not paused
	if paused:
		EventBus.game_resumed.emit()
	else:
		EventBus.game_paused.emit()
