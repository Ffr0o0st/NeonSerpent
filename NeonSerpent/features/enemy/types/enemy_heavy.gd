## EnemyHeavy — 重装兵：慢速暗红方块，带周期性护盾
class_name EnemyHeavy extends EnemyBase

var _shield_active: bool = false
var _shield_timer: float = 0.0
var _shield_cooldown_timer: float = 0.0


func _ready() -> void:
	super._ready()
	_shield_cooldown_timer = enemy_data.shield_cooldown if enemy_data else 6.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if enemy_data and enemy_data.has_shield:
		if _shield_active:
			_shield_timer -= delta
			if _shield_timer <= 0.0:
				_shield_active = false
				_shield_cooldown_timer = enemy_data.shield_cooldown
		else:
			_shield_cooldown_timer -= delta
			if _shield_cooldown_timer <= 0.0:
				_shield_active = true
				_shield_timer = enemy_data.shield_duration
	queue_redraw()


## 护盾期间免疫伤害
func take_damage(amount: float) -> void:
	if _shield_active: return
	super.take_damage(amount)


func _draw() -> void:
	super._draw()
	if _shield_active:
		var s: float = (enemy_data.visual_size if enemy_data else 48.0) / 2.0 + 6.0
		draw_circle(Vector2.ZERO, s, Color(1, 1, 1, 0.3), false, 2.0)
