## TurretMachinegun — 机枪炮台（蛇身旋转挂件）
## 绘制底座 + 旋转炮塔 + 枪管指向目标 + 瘫痪闪烁
extends Node2D

@export var turret_data: Resource = null

var is_disabled: bool = false
var _fire_timer: float = 0.0
var _current_target: Node2D = null
var _range_px: float = 160.0
var _projectile_parent: Node2D = null
var _flicker_timer: float = 0.0
var _aim_angle: float = 0.0  # 当前瞄准角度（弧度）
var _target_angle: float = 0.0  # 目标角度（平滑旋转）

const _projectile_scene: PackedScene = preload("res://features/projectile/projectile_base.tscn")
const ROTATE_SPEED: float = 8.0  # 旋转速度（弧度/秒）
var _sprite: Sprite2D = null


func _ready() -> void:
	_sprite = $Sprite
	_sprite.scale = Vector2(0.7, 0.7)
	if not turret_data:
		var td_script: Script = load("res://features/turret/data/turret_data.gd")
		turret_data = td_script.new()
		turret_data.set("display_name", "Machinegun")
		turret_data.set("dps", 40.0)
		turret_data.set("bullet_speed", 640.0)
		turret_data.set("range_cells", 5)
		turret_data.set("fire_interval", 0.25)
		turret_data.set("bullet_color", Color("#FFFF44"))
		turret_data.set("bullet_size", 4.0)
	if turret_data:
		_range_px = turret_data.get("range_cells") * GridUtils.config.cell_size


func _process(delta: float) -> void:
	if get_tree().paused: return
	if is_disabled:
		_flicker_timer += delta
		queue_redraw()
		return

	_fire_timer += delta
	var interval: float = turret_data.get("fire_interval") if turret_data else 0.25
	if _fire_timer >= interval:
		_fire_timer = 0.0
		_try_fire()

	# 平滑旋转瞄准
	_aim_angle = lerp_angle(_aim_angle, _target_angle, min(ROTATE_SPEED * delta, 1.0))
	_sprite.rotation = _aim_angle
	queue_redraw()


func _try_fire() -> void:
	_current_target = _find_target()
	if _current_target:
		_target_angle = (position.angle_to_point(_current_target.position))
		_fire(_current_target)


func _find_target() -> Node2D:
	var best_dist: float = _range_px
	var best_target: Node2D = null
	var enemies: Array = GameState.cached_enemies
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		var en: Node2D = enemy as Node2D
		var dist: float = position.distance_to(en.position)
		if dist < best_dist:
			best_dist = dist
			best_target = en
	return best_target


func _fire(target_node: Node2D) -> void:
	if not _projectile_parent: return
	var bullet: Node2D = _projectile_scene.instantiate()
	bullet.position = position + Vector2.RIGHT.rotated(_aim_angle) * 14.0
	bullet.set("target", target_node)
	bullet.set("speed", turret_data.get("bullet_speed") if turret_data else 600.0)
	var dps_val: float = turret_data.get("dps") if turret_data else 40.0
	var interval: float = turret_data.get("fire_interval") if turret_data else 0.25
	bullet.set("damage", dps_val * interval)
	bullet.set("bullet_color", turret_data.get("bullet_color") if turret_data else Color.YELLOW)
	bullet.set("bullet_radius", turret_data.get("bullet_size") if turret_data else 4.0)
	bullet.set("pierce_count", turret_data.get("pierce_count") if turret_data else 0)
	_projectile_parent.add_child(bullet)


func set_projectile_parent(parent: Node2D) -> void:
	_projectile_parent = parent


func _draw() -> void:
	var gun_color: Color = turret_data.get("bullet_color") if turret_data else Color.YELLOW
	if is_disabled:
		var flicker: float = abs(sin(_flicker_timer * 8.0))
		gun_color = Color(1.0, 0.1, 0.1).lerp(Color(0.3, 0, 0), flicker)

	# 底座——深色圆环，锚定在蛇身上
	var base_r: float = 9.0
	draw_circle(Vector2.ZERO, base_r, Color(0.08, 0.08, 0.08, 0.85))
	draw_arc(Vector2.ZERO, base_r, 0, TAU, 12, Color(gun_color, 0.4), 1.5)

	# 炮塔主体——从底座中心向瞄准方向延伸
	var body_len: float = 7.0
	var body_dir: Vector2 = Vector2.RIGHT.rotated(_aim_angle)
	var body_end: Vector2 = body_dir * body_len
	# 炮塔外壳（矩形）
	var perp: Vector2 = body_dir.rotated(TAU / 4.0) * 5.0
	var rect_points: PackedVector2Array = [
		Vector2.ZERO + perp,
		body_end + perp,
		body_end - perp,
		Vector2.ZERO - perp,
	]
	draw_polygon(rect_points, PackedColorArray([
		Color(gun_color, 0.4),
		Color(gun_color, 0.5),
		Color(gun_color, 0.5),
		Color(gun_color, 0.4),
	]))

	# 枪管——从炮塔前端延伸
	var barrel_len: float = 14.0
	var barrel_w: float = 2.5
	var barrel_start: Vector2 = body_end
	var barrel_end: Vector2 = body_end + body_dir * barrel_len
	var barrel_perp: Vector2 = body_dir.rotated(TAU / 4.0) * barrel_w
	var barrel_points: PackedVector2Array = [
		barrel_start + barrel_perp,
		barrel_end + barrel_perp,
		barrel_end - barrel_perp,
		barrel_start - barrel_perp,
	]
	draw_polygon(barrel_points, PackedColorArray([
		Color(gun_color, 0.7),
		gun_color,
		gun_color,
		Color(gun_color, 0.7),
	]))

	# 枪口闪光
	if not is_disabled:
		draw_circle(barrel_end, barrel_w * 2.0, Color(gun_color, 0.5))

	# 射程指示
	draw_circle(Vector2.ZERO, _range_px, Color(gun_color, 0.02), false, 1.0)
