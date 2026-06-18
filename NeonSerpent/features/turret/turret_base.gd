## TurretBase — 炮台基类（不使用 class_name 类型标注以避开编译顺序问题）
extends Node2D

@export var turret_data: Resource = null  # TurretData

var is_disabled: bool = false
var _fire_timer: float = 0.0
var _current_target: Node2D = null
var _range_px: float = 160.0
var _projectile_parent: Node2D = null

const _projectile_scene: PackedScene = preload("res://features/projectile/projectile_base.tscn")


func _ready() -> void:
	if turret_data:
		_range_px = turret_data.get("range_cells") * GridUtils.config.cell_size


func _process(delta: float) -> void:
	if get_tree().paused or is_disabled: return
	_fire_timer += delta
	var interval: float = turret_data.get("fire_interval") if turret_data else 0.25
	if _fire_timer >= interval:
		_fire_timer = 0.0
		_try_fire()


func _try_fire() -> void:
	_current_target = _find_target()
	if _current_target:
		_fire(_current_target)


func _find_target() -> Node2D:
	var best_dist: float = _range_px
	var best_target: Node2D = null
	var enemies: Array = GameState.cached_enemies
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		var en = enemy as Node2D
		var dist = position.distance_to(en.position)
		if dist < best_dist:
			best_dist = dist
			best_target = en
	return best_target


func _fire(target_node: Node2D) -> void:
	if not _projectile_parent: return
	var bullet: Node2D = _projectile_scene.instantiate()
	bullet.position = position
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
	if not turret_data: return
	var c: Color = turret_data.get("bullet_color") if turret_data else Color.YELLOW
	c = Color(c, 0.6)
	draw_circle(Vector2.ZERO, 10.0, c)
	draw_circle(Vector2.ZERO, 15.0, Color(c, 0.15))
