## Core — 需守护的核心实体
extends Node2D

@export var max_hp: int = 200
@export var current_hp: int = 200:
	set(v):
		current_hp = clampi(v, 0, max_hp)
		if current_hp <= 0:
			_die()

@export var texture: Texture2D = null
@export var core_color: Color = Color("#FFD700")
@export var shield_color: Color = Color("#AADDFF")
@export var core_radius: float = 20.0
@export var shield_radius: float = 28.0
@export var damage_interval: float = 0.5
@export var damage_cooldown_per_enemy: bool = false

var _sprite: Sprite2D = null
var _has_sprite: bool = false
var _pulse_timer: float = 0.0
var _overlapping_enemies: Array = []  # Array[Node2D]
var _enemy_cooldowns: Dictionary = {}  # Dictionary[ObjectID: float]


func _ready() -> void:
	_sprite = $Sprite
	if _sprite.texture:
		_sprite.show()
		_has_sprite = true
	else:
		_sprite.hide()

	if GridUtils.config:
		position = GridUtils.cell_to_world(GridUtils.config.core_position)
		max_hp = GridUtils.config.core_max_hp
		current_hp = max_hp

	var ha = $HitArea as Area2D
	if ha:
		ha.body_entered.connect(_on_enemy_entered)
		ha.body_exited.connect(_on_enemy_exited)

	GameState.core_hp = current_hp


func _process(delta: float) -> void:
	if get_tree().paused: return

	_pulse_timer += delta

	# 清理无效引用并对每个敌人独立计时造成伤害
	var to_remove: Array = []
	for enemy in _overlapping_enemies:
		if not is_instance_valid(enemy):
			to_remove.append(enemy)
			continue
		var eid: int = enemy.get_instance_id()
		var cd: float = _enemy_cooldowns.get(eid, 0.0)
		cd -= delta
		if cd <= 0.0:
			cd = damage_interval
			if enemy.has_method("get_core_damage"):
				take_damage(enemy.get_core_damage())
		_enemy_cooldowns[eid] = cd

	for e in to_remove:
		_overlapping_enemies.erase(e)
		_enemy_cooldowns.erase(e.get_instance_id())

	queue_redraw()


func _draw() -> void:
	var hp_ratio = float(current_hp) / float(max_hp)
	var pulse_freq = lerpf(1.0, 4.0, 1.0 - hp_ratio)
	var pulse = 1.0 + sin(_pulse_timer * pulse_freq * TAU) * 0.15

	if not _has_sprite:
		# 护盾光晕 + 核心球体（fallback，有 Sprite 时跳过）
		draw_circle(Vector2.ZERO, shield_radius * pulse, Color(shield_color, 0.15))
		draw_circle(Vector2.ZERO, core_radius * pulse, core_color)
		draw_circle(Vector2.ZERO, core_radius * pulse * 1.3, Color(core_color, 0.3))

	# 血条（始终绘制）
	var bw = 60.0; var bh = 6.0; var by = -shield_radius - 10.0
	draw_rect(Rect2(-bw / 2, by, bw, bh), Color.BLACK, false, 1.0)
	draw_rect(Rect2(-bw / 2, by, bw * hp_ratio, bh), core_color)


func take_damage(amount: int) -> void:
	current_hp -= amount
	GameState.core_hp = current_hp
	EventBus.core_damaged.emit(current_hp, max_hp)
	# 全屏红光脉冲
	var cl = GameState.canvas_layer
	if cl:
			_flash_screen(cl, Color(1.0, 0.0, 0.0, 0.5))


func _flash_screen(cl: CanvasLayer, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = Color(1, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(rect)
	var tw := get_tree().create_tween()
	tw.tween_property(rect, "color", color, 0.05)
	tw.tween_property(rect, "color", Color(1, 0, 0, 0), 0.2)
	tw.tween_callback(rect.queue_free)


func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	GameState.core_hp = current_hp


func _die() -> void:
	EventBus.core_destroyed.emit()


func _on_enemy_entered(body: Node2D) -> void:
	if body not in _overlapping_enemies:
		_overlapping_enemies.append(body)
		_enemy_cooldowns[body.get_instance_id()] = damage_interval * 0.5  # 进入立即造成首次伤害


func _on_enemy_exited(body: Node2D) -> void:
	var idx = _overlapping_enemies.find(body)
	if idx >= 0:
		_overlapping_enemies.remove_at(idx)
		_enemy_cooldowns.erase(body.get_instance_id())
