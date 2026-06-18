## TurretManager — 蛇头武器管理（蛇身炮台由 SnakeBodySegment 自行处理）
extends Node

var head_turret: Node2D = null
var _snake_head: Node2D = null
var _projectile_parent: Node2D = null
var _relic_manager: Node = null

const HEAD_DPS_BOOST: float = 1.3
const HEAD_RANGE_BONUS: int = 1


func _ready() -> void:
	var p = get_parent()
	if p:
		_snake_head = p.find_child("SnakeHead", true, false) as Node2D
		_projectile_parent = p.find_child("Projectiles", true, false) as Node2D
		_relic_manager = p.find_child("RelicManager", true, false)
	if not _projectile_parent:
		_projectile_parent = Node2D.new(); _projectile_parent.name = "Projectiles"
		if p: p.add_child(_projectile_parent)
	_create_head_weapon()


func _create_head_weapon() -> void:
	var scene: PackedScene = load("res://features/turret/types/turret_machinegun.tscn")
	var turret = scene.instantiate() as Node2D
	turret.name = "HeadTurret"
	head_turret = turret

	var td_script: Script = load("res://features/turret/data/turret_data.gd")
	var td: Resource = td_script.new()
	turret.set("turret_data", td)
	td.set("dps", 40.0 * HEAD_DPS_BOOST)
	td.set("range_cells", 5 + HEAD_RANGE_BONUS)
	td.set("bullet_color", Color("#00FFFF"))
	td.set("bullet_size", 5.0)
	_apply_relic_bonuses(td)
	turret.set("is_disabled", false)
	turret.call("set_projectile_parent", _projectile_parent)
	var parent = get_parent()
	if parent: parent.add_child(turret)


func _process(_delta: float) -> void:
	if get_tree().paused: return
	if head_turret and _snake_head: head_turret.position = _snake_head.position


func _apply_relic_bonuses(td: Resource) -> void:
	if not _relic_manager: return
	var dm: float = _relic_manager.call("get_damage_mult")
	var fm: float = _relic_manager.call("get_fire_interval_mult")
	var rb: int = _relic_manager.call("get_range_bonus")
	td.set("dps", td.get("dps") * dm)
	td.set("fire_interval", td.get("fire_interval") * fm)
	td.set("range_cells", td.get("range_cells") + rb)
