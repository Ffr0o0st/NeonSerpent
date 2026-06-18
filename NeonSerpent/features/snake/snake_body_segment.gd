## SnakeBodySegment — 蛇身段
## 普通段=霓虹蓝圆点。炮台段=旋转炮塔，自动瞄准射击。
class_name SnakeBodySegment extends Node2D

var grid_cell: Vector2i = Vector2i.ZERO
var is_turret: bool = false
var turret_type: String = "machinegun"

var _is_disrupted: bool = false
var _flicker_timer: float = 0.0
var _fire_timer: float = 0.0
var _current_target: Node2D = null
var _aim_angle: float = 0.0
var _target_angle: float = 0.0
var _projectile_parent: Node2D = null
const _projectile_scene: PackedScene = preload("res://features/projectile/projectile_base.tscn")
@export var texture: Texture2D = null
@export var texture_disrupted: Texture2D = null
var _sprite: Sprite2D = null
var _has_sprite: bool = false

@export var normal_color: Color = Color("#0088FF")
@export var circle_radius: float = 20.0
@export var glow_alpha: float = 0.3

# 炮台参数（按类型）
const TURRET_CONFIG: Dictionary = {
	"machinegun": {dps=40.0, speed=640.0, range=6, interval=0.5, color=Color("#FFFF44"), size=4.0, type="bullet"},
	"mortar":     {dps=15.0, speed=224.0, range=6, interval=2.0, color=Color("#FFAA00"), size=6.0, type="splash"},
	"laser":      {dps=48.0, speed=9999.0, range=6, interval=1.0, color=Color("#FF3333"), size=2.0, type="laser"},
	"ice":        {dps=15.0, speed=320.0, range=6, interval=1.0, color=Color("#88DDFF"), size=4.0, type="ice"},
	"flame":      {dps=60.0, speed=160.0, range=6, interval=0.3, color=Color("#FF6600"), size=5.0, type="flame"},
	"lightning":  {dps=28.0, speed=9999.0, range=6, interval=1.2, color=Color("#FFFFFF"), size=2.0, type="lightning"},
}


func _ready() -> void:
	_sprite = $Sprite
	if _sprite.texture:
		_has_sprite = true
		var cs: float = GridUtils.config.cell_size
		_sprite.scale = Vector2(cs / _sprite.texture.get_size().x, cs / _sprite.texture.get_size().x)
	else:
		_sprite.hide()

func set_cell(cell: Vector2i) -> void: grid_cell = cell
func set_disrupted(disrupted: bool) -> void: _is_disrupted = disrupted
func set_projectile_parent(parent: Node2D) -> void: _projectile_parent = parent


func _process(delta: float) -> void:
	if get_tree().paused: return
	if _is_disrupted:
		_flicker_timer += delta
		if _has_sprite and texture_disrupted:
			_sprite.texture = texture_disrupted
		if not _has_sprite:
			queue_redraw()
		return
	if not is_turret: return

	# 炮台段：自动瞄准 + 射击
	var cfg: Dictionary = TURRET_CONFIG.get(turret_type, TURRET_CONFIG["machinegun"])
	var range_px: float = cfg.range * GridUtils.config.cell_size
	_fire_timer += delta
	if _fire_timer >= cfg.interval:
		_fire_timer = 0.0
		_try_fire(cfg, range_px)
	_aim_angle = lerp_angle(_aim_angle, _target_angle, min(8.0 * delta, 1.0))
	queue_redraw()


func _try_fire(cfg: Dictionary, range_px: float) -> void:
	_current_target = _find_target(range_px)
	if _current_target:
		_target_angle = position.angle_to_point(_current_target.position)
		_fire(cfg)


func _find_target(range_px: float) -> Node2D:
	var best_dist: float = range_px
	var best: Node2D = null
	for enemy in GameState.cached_enemies:
		if not is_instance_valid(enemy): continue
		var en: Node2D = enemy as Node2D
		var dist: float = position.distance_to(en.position)
		if dist < best_dist: best_dist = dist; best = en
	return best


func _fire(cfg: Dictionary) -> void:
	if not _projectile_parent: return
	# 应用遗物进化倍率
	var evo_mult: float = 1.0
	var rm = GameState.relic_manager
	if rm and rm.has_method("get_evo_mult"):
		evo_mult = rm.call("get_evo_mult", turret_type)
	var ptype: String = cfg.type
	var color: Color = cfg.color

	match ptype:
		"laser":
			if _current_target.has_method("take_damage"):
				_current_target.call("take_damage", cfg.dps * 1.0 * evo_mult)
			# 穿透线：向目标方向延伸到最大射程
			var dir: Vector2 = (_current_target.position - position).normalized()
			var max_range: float = cfg.range * GridUtils.config.cell_size
			for enemy in GameState.cached_enemies:
				if enemy == _current_target or not is_instance_valid(enemy): continue
				var en: Node2D = enemy as Node2D
				var to_en: Vector2 = en.position - position
				var proj: float = to_en.dot(dir)
				if proj > 0 and proj < max_range:
					if (to_en - dir * proj).length() < 24.0:
						if en.has_method("take_damage"): en.call("take_damage", cfg.dps * 0.3)
			# 可见光束——延伸到最大射程，不是止于目标
			var beam: Node2D = _projectile_scene.instantiate()
			beam.position = position
			beam.set("projectile_type", "laser")
			beam.set("bullet_color", color)
			beam.set("bullet_radius", 2.0)
			beam.set("beam_start", position)
			beam.set("beam_end", position + dir * max_range * 2.0)
			beam.set("_lifetime", 0.08)
			beam.set("target", null)
			_projectile_parent.add_child(beam)

		"lightning":
			var damaged: Array = []
			_chain_damage(_current_target, 3, damaged, cfg, evo_mult)
			_spawn_lightning_arc(damaged)

		"flame":
			var p: Node2D = _spawn_projectile(ptype, color, cfg, _current_target, evo_mult)
			if p: p.set("_lifetime", 0.3)

		_:
			_spawn_projectile(ptype, color, cfg, _current_target, evo_mult)


func _spawn_projectile(ptype: String, color: Color, cfg: Dictionary, target: Node2D, evo_mult: float = 1.0) -> Node2D:
	var bullet: Node2D = _projectile_scene.instantiate()
	bullet.position = position + Vector2.RIGHT.rotated(_aim_angle) * 14.0
	bullet.set("target", target)
	bullet.set("speed", cfg.speed)
	bullet.set("damage", cfg.dps * cfg.interval * evo_mult)
	bullet.set("bullet_color", color)
	bullet.set("bullet_radius", cfg.size)
	bullet.set("projectile_type", ptype)
	if ptype == "splash": bullet.set("splash_radius", 96.0)
	if ptype == "ice":
		bullet.set("slow_amount", 0.3)
		bullet.set("slow_duration", 3.0)
	_projectile_parent.add_child(bullet)
	return bullet


func _chain_damage(target: Node2D, remaining: int, damaged: Array, cfg: Dictionary, evo_mult: float = 1.0) -> void:
	if remaining <= 0 or not is_instance_valid(target) or target in damaged: return
	if target.has_method("take_damage"):
		target.call("take_damage", cfg.dps * 1.2 * remaining / 3.0 * evo_mult)
	damaged.append(target)
	var best: Node2D = null; var best_dist: float = 96.0
	for enemy in GameState.cached_enemies:
		if enemy == target or enemy in damaged or not is_instance_valid(enemy): continue
		var en: Node2D = enemy as Node2D
		var dist: float = target.position.distance_to(en.position)
		if dist < best_dist: best_dist = dist; best = en
	if best: _chain_damage(best, remaining - 1, damaged, cfg)


func _spawn_lightning_arc(damaged: Array) -> void:
	var arc: Node2D = _projectile_scene.instantiate()
	arc.position = position
	arc.set("beam_start", position)
	arc.set("beam_targets", damaged)
	arc.set("projectile_type", "lightning")
	arc.set("bullet_color", Color("#FFFFFF"))
	arc.set("_lifetime", 0.2)
	_projectile_parent.add_child(arc)


func _draw() -> void:
	match is_turret:
		true: _draw_turret()
		false: _draw_normal()


func _draw_normal() -> void:
	if _has_sprite: return
	var color: Color = normal_color
	if _is_disrupted:
		var flicker: float = abs(sin(_flicker_timer * 8.0))
		color = Color("#FF2222").lerp(Color("#FF2222", 0.2), flicker)
	draw_circle(Vector2.ZERO, circle_radius, color)
	draw_circle(Vector2.ZERO, circle_radius * 1.5, Color(color, glow_alpha))


func _draw_turret() -> void:
	var cfg: Dictionary = TURRET_CONFIG.get(turret_type, TURRET_CONFIG["machinegun"])
	var gun_color: Color = cfg.color
	if _is_disrupted:
		var flicker: float = abs(sin(_flicker_timer * 8.0))
		gun_color = Color(1.0, 0.1, 0.1).lerp(Color(0.3, 0, 0), flicker)

	if not _has_sprite:
		# 蛇身底座（和普通段一样的发光圆）
		draw_circle(Vector2.ZERO, circle_radius, normal_color)
		draw_circle(Vector2.ZERO, circle_radius * 1.5, Color(normal_color, glow_alpha))
		# 炮塔基座环
		draw_circle(Vector2.ZERO, circle_radius + 4.0, Color(0.1, 0.1, 0.1, 0.7))
		draw_arc(Vector2.ZERO, circle_radius + 4.0, 0, TAU, 12, Color(gun_color, 0.5), 2.0)

	# 炮塔主体（炮台方向指示，始终绘制覆盖在 Sprite 上）
	var body_dir: Vector2 = Vector2.RIGHT.rotated(_aim_angle)
	var body_len: float = 6.0
	var body_end: Vector2 = body_dir * body_len
	var perp: Vector2 = body_dir.rotated(TAU / 4.0) * 4.0
	draw_polygon(PackedVector2Array([Vector2.ZERO+perp, body_end+perp, body_end-perp, Vector2.ZERO-perp]),
		PackedColorArray([Color(gun_color,0.4), Color(gun_color,0.5), Color(gun_color,0.5), Color(gun_color,0.4)]))

	# 枪管
	var barrel_len: float = 12.0; var barrel_w: float = 2.0
	var bs: Vector2 = body_end; var be: Vector2 = body_end + body_dir * barrel_len
	var bp: Vector2 = body_dir.rotated(TAU/4.0) * barrel_w
	draw_polygon(PackedVector2Array([bs+bp, be+bp, be-bp, bs-bp]),
		PackedColorArray([Color(gun_color,0.7), gun_color, gun_color, Color(gun_color,0.7)]))

	if not _is_disrupted: draw_circle(be, barrel_w * 2.5, Color(gun_color, 0.5))
