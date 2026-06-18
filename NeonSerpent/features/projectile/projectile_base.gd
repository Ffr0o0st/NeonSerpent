## ProjectileBase — 子弹实体，支持多种弹道类型
class_name ProjectileBase extends Node2D

var speed: float = 600.0
var damage: float = 10.0
var target: Node2D = null
var bullet_color: Color = Color.YELLOW
var bullet_radius: float = 4.0
var pierce_count: int = 0
var projectile_type: String = "bullet"
var splash_radius: float = 0.0
var slow_amount: float = 0.0
var slow_duration: float = 0.0
var beam_start: Vector2 = Vector2.ZERO
var beam_end: Vector2 = Vector2.ZERO
var beam_targets: Array = []

var _pierced: int = 0
var _lifetime: float = 5.0
var _trail: Array = []  # 拖尾位置记录（最多 8 帧）
const RING_SCRIPT: Script = preload("res://features/vfx/explosion_ring.gd")


func _physics_process(delta: float) -> void:
	if get_tree().paused: return
	_lifetime -= delta
	if _lifetime <= 0:
		if projectile_type == "flame" or projectile_type == "splash":
			_spawn_explosion_ring(bullet_radius * 10.0, bullet_color)
		queue_free(); return

	match projectile_type:
		"laser":
			if target and is_instance_valid(target):
				beam_start = position; beam_end = target.position
			queue_redraw(); return
		"lightning":
			queue_redraw(); return
		"flame":
			if target and is_instance_valid(target):
				position = position.move_toward(target.position, speed * delta)
			# 火焰范围灼烧
			for enemy in GameState.cached_enemies:
				if not is_instance_valid(enemy): continue
				var en: Node2D = enemy as Node2D
				if position.distance_to(en.position) < 32.0:
					if en.has_method("take_damage"):
						en.call("take_damage", damage * delta * 3.0)
			_add_trail()
			queue_redraw(); return
		"splash", "ice", "bullet":
			if target and is_instance_valid(target):
				position = position.move_toward(target.position, speed * delta)
				if position.distance_to(target.position) < 12.0: _hit_target()
			else: queue_free()

	_add_trail()
	queue_redraw()


func _add_trail() -> void:
	_trail.push_front(position)
	while _trail.size() > 8:
		_trail.pop_back()


func _draw() -> void:
	_draw_trail()
	match projectile_type:
		"laser":
			draw_line(beam_start - position, beam_end - position, bullet_color, bullet_radius * 2.0)
			draw_line(beam_start - position, beam_end - position, Color(bullet_color, 0.3), bullet_radius * 4.0)
		"lightning": _draw_lightning_arcs()
		"flame":
			# 火焰主体 + 随机火花偏移
			for i in range(3):
				var off: Vector2 = Vector2(randf_range(-6, 6), randf_range(-6, 6))
				draw_circle(off, bullet_radius * 1.5, Color(bullet_color, 0.4))
			draw_circle(Vector2.ZERO, bullet_radius, bullet_color)
		"splash":
			draw_circle(Vector2.ZERO, bullet_radius * 2.0, bullet_color)
			draw_circle(Vector2.ZERO, bullet_radius * 3.0, Color(bullet_color, 0.15))
		"ice":
			draw_circle(Vector2.ZERO, bullet_radius, bullet_color)
			draw_circle(Vector2.ZERO, bullet_radius * 2.0, Color(bullet_color, 0.3))
		_:
			draw_circle(Vector2.ZERO, bullet_radius, bullet_color)


func _draw_trail() -> void:
	# 为 bullet/splash/ice/flame 类型绘制位置历史拖尾
	if projectile_type in ["laser", "lightning"]: return
	var count: int = _trail.size()
	if count < 2: return
	for i in range(count):
		var local_pos: Vector2 = _trail[i] - position
		var alpha: float = 0.7 * (1.0 - float(i) / float(count))
		var r: float = bullet_radius * (1.0 - float(i) / float(count) * 0.5)
		if r < 1.5: continue
		draw_circle(local_pos, r, Color(bullet_color.lightened(0.2), alpha))


func _draw_lightning_arcs() -> void:
	var prev: Vector2 = beam_start - position
	for tgt in beam_targets:
		if not is_instance_valid(tgt): continue
		var end: Vector2 = (tgt as Node2D).position - position
		for i in range(5):
			var t0: float = float(i) / 5; var t1: float = float(i + 1) / 5
			var p0: Vector2 = prev.lerp(end, t0); var p1: Vector2 = prev.lerp(end, t1)
			if i < 4: p1 += Vector2(randf_range(-12, 12), randf_range(-12, 12))
			draw_line(p0, p1, bullet_color, 2.0)
		prev = end
	draw_circle(prev, 6.0, Color(bullet_color, 0.6))


func _hit_target() -> void:
	match projectile_type:
		"splash": _splash_hit()
		"ice": _ice_hit()
		_: _normal_hit()


func _normal_hit() -> void:
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.call("take_damage", damage)
		_pierced += 1
		if _pierced > pierce_count: queue_free()
	else: queue_free()


func _spawn_explosion_ring(radius: float, color: Color) -> void:
	var parent = get_parent()
	if not parent: return
	var ring := Node2D.new()
	ring.set_script(RING_SCRIPT)
	ring.position = position
	ring.set("ring_color", color)
	ring.set("max_radius", radius)
	parent.add_child(ring)

func _splash_hit() -> void:
	for enemy in GameState.cached_enemies:
		if not is_instance_valid(enemy): continue
		var en: Node2D = enemy as Node2D
		if position.distance_to(en.position) < splash_radius:
			if en.has_method("take_damage"): en.call("take_damage", damage)
	_spawn_explosion_ring(splash_radius, bullet_color)
	queue_free()


func _ice_hit() -> void:
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.call("take_damage", damage)
		if target.has_method("apply_slow"):
			target.call("apply_slow", slow_amount, slow_duration)
	queue_free()
