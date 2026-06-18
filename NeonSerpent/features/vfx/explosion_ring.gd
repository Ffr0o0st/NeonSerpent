## ExplosionRing — 自包含爆炸扩散光圈
## 创建后自动扩大+淡出→self.queue_free。
## 用于迫击炮溅射、火焰到期等范围伤害可视化。
extends Node2D

var ring_color: Color = Color.ORANGE
var max_radius: float = 96.0
var _lifetime: float = 0.35
var _elapsed: float = 0.0


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	if get_tree().paused: return
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var ratio: float = _elapsed / _lifetime  # 0→1
	var radius: float = max_radius * ratio
	var alpha: float = 1.0 - ratio
	# 主光圈
	draw_circle(Vector2.ZERO, radius, Color(ring_color, alpha * 0.4), false, 2.0)
	# 辉光外环
	draw_circle(Vector2.ZERO, radius * 1.15, Color(ring_color, alpha * 0.15), false, 3.0)
