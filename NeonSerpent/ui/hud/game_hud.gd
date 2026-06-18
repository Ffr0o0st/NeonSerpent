## GameHUD — 游戏内 HUD 面板
## 显示核心血量、波次信息、食物进度、蛇长、炮台状态。
## 监听 EventBus 信号更新，不直接引用任何游戏实体。
class_name GameHUD extends Control

# === 顶部面板 ===
@onready var _core_health_bar: TextureProgressBar = $TopPanel/HBoxTop/CoreHealthBar
@onready var _wave_label: Label = $TopPanel/HBoxTop/WaveLabel
@onready var _kill_label: Label = $TopPanel/HBoxTop/KillLabel

# === 底部面板 ===
@onready var _food_progress: HBoxContainer = $BottomPanel/HBoxBottom/FoodProgress
@onready var _snake_length_label: Label = $BottomPanel/HBoxBottom/SnakeLength
@onready var _food_count_label: Label = $BottomPanel/HBoxBottom/FoodCount

# === 内部 ===
var _max_food_for_growth: int = 3
var _food_collected: int = 0
var _kill_count: int = 0


func _ready() -> void:
	EventBus.core_damaged.connect(_on_core_damaged)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.food_collected.connect(_on_food_collected)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.level_completed.connect(_on_level_completed)

	# 初始化显示
	_update_health_bar(GameState.core_hp, GameState.CORE_MAX_HP)
	_update_wave_display(GameState.current_level, GameState.current_wave)
	_update_food_display()


func _on_core_damaged(current_hp: int, max_hp: int) -> void:
	_update_health_bar(current_hp, max_hp)


func _on_enemy_killed(_type: String, _pos: Vector2, _food: int) -> void:
	_kill_count += 1
	GameState.kill_count = _kill_count
	_kill_label.text = "击杀: %d" % _kill_count


func _on_food_collected(_amount: int) -> void:
	_food_collected += 1
	_update_food_display()


func _on_wave_started(wave_index: int) -> void:
	_update_wave_display(GameState.current_level, wave_index)


func _on_level_completed(level_index: int) -> void:
	_update_wave_display(level_index, 0)


func _update_health_bar(current: int, maximum: int) -> void:
	if _core_health_bar:
		_core_health_bar.max_value = float(maximum)
		_core_health_bar.value = float(current)
		# 血量越低颜色越红
		var ratio = float(current) / float(maximum)
		_core_health_bar.tint_progress = Color(
			lerpf(1.0, 0.0, 1.0 - ratio),
			lerpf(0.84, 0.0, 1.0 - ratio),
			0.0
		)


func _update_wave_display(level: int, wave: int) -> void:
	if _wave_label:
		_wave_label.text = "第%d关 · 第%d波" % [level, wave]


func _update_food_display() -> void:
	if _snake_length_label:
		_snake_length_label.text = "蛇长: %d" % GameState.snake_length
	if _food_count_label:
		# 获取当前成长成本
		var cost = _get_growth_cost()
		_food_count_label.text = "食物: %d/%d" % [_food_collected % cost, cost]
	if _food_progress:
		var cost = _get_growth_cost()
		var current = _food_collected % cost
		for i in range(_food_progress.get_child_count()):
			var dot = _food_progress.get_child(i) as ColorRect
			if dot:
				dot.color = Color.GREEN if i < current else Color(0.2, 0.2, 0.2)


func _get_growth_cost() -> int:
	var bl = GameState.snake_length
	if bl <= 8: return 3
	elif bl <= 16: return 4
	elif bl <= 24: return 5
	elif bl <= 30: return 6
	else: return 7
