## EnemyBehemoth — 增幅巨兽：Boss，每8s光环+15%移速/伤害给周围敌人
## 策划案：HP 2000→4000, 移速 0.3, 核伤 5, 食物 10, 每8s光环+15%
class_name EnemyBehemoth extends EnemyBase

var _aura_timer: float = 0.0
var _aura_active: bool = false
var _aura_radius: float = 0.0


func _ready() -> void:
	super._ready()
	_aura_radius = GridUtils.config.cell_size * 5.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_aura_timer += delta
	if _aura_timer >= 8.0:
		_aura_timer = 0.0
		_aura_active = true
		_apply_aura()
	# 光环淡出
	if _aura_active:
		_aura_timer = 0.0  # 保持 1 帧
		_aura_active = false
	queue_redraw()


func _apply_aura() -> void:
	var enemies: Array = GameState.cached_enemies
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy): continue
		var en: Node2D = enemy as Node2D
		if position.distance_to(en.position) < _aura_radius:
			if en.has_method("apply_boost"):
					en.call("apply_boost", 0.15)


func _draw() -> void:
	super._draw()
	# 扩散光环波
	var s: float = (enemy_data.visual_size if enemy_data else 64.0) / 2.0
	var pulse: float = 1.0 + sin(_aura_timer / 8.0 * TAU) * 0.3
	draw_circle(Vector2.ZERO, s * pulse + 8.0, Color(1.0, 0.0, 0.0, 0.2), false, 3.0)
	if _aura_active:
		draw_circle(Vector2.ZERO, _aura_radius, Color(1.0, 0.0, 0.0, 0.1))
