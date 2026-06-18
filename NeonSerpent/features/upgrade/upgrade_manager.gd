## UpgradeManager — 升级管理（仅炮台段触发）
## 监听 SnakeManager.turret_growth_ready → 弹出 3 选 1 面板
class_name UpgradeManager extends Node

var _snake_manager: Node = null
var _upgrade_panel: Control = null
var _available_turrets: Array = ["machinegun", "mortar", "laser", "ice", "flame", "lightning"]


func _ready() -> void:
	call_deferred(&"_init_refs")


func _init_refs() -> void:
	var p = get_parent()
	if p: _snake_manager = p.find_child("SnakeManager", true, false)
	if _snake_manager and _snake_manager.has_signal("turret_growth_ready"):
		_snake_manager.turret_growth_ready.connect(_on_turret_growth_ready)
	_create_upgrade_panel()


func _on_turret_growth_ready(_seg_idx: int) -> void:
	if not _upgrade_panel: _create_upgrade_panel()
	if not _upgrade_panel: return
	_flash_white()
	_generate_options()
	_upgrade_panel.show()


func _flash_white() -> void:
	Engine.time_scale = 0.2
	var cl = GameState.canvas_layer
	if not cl: return
	var rect := ColorRect.new()
	rect.color = Color(1, 1, 1, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(rect)
	var tw := get_tree().create_tween()
	tw.tween_property(rect, "color", Color(1, 1, 1, 0.6), 0.06)
	tw.tween_property(rect, "color", Color(1, 1, 1, 0), 0.2)
	tw.tween_callback(rect.queue_free)
	tw.tween_callback(func(): Engine.time_scale = 1.0)


func _generate_options() -> void:
	var options: Array = []
	var pool: Array = _available_turrets.duplicate()
	pool.shuffle()
	for i in range(min(3, pool.size())):
		options.append(pool[i])
	_upgrade_panel.call("set_options", options)


func _on_option_selected(turret_type: String) -> void:
	if not _upgrade_panel: return
	_upgrade_panel.hide()
	if _snake_manager and _snake_manager.has_method("grow_turret_segment"):
		_snake_manager.call("grow_turret_segment", turret_type)


func _create_upgrade_panel() -> void:
	if _upgrade_panel: return
	var panel_scene = load("res://features/upgrade/upgrade_panel.tscn") as PackedScene
	if not panel_scene: return
	_upgrade_panel = panel_scene.instantiate() as Control
	if not _upgrade_panel.option_selected.is_connected(_on_option_selected):
		_upgrade_panel.option_selected.connect(_on_option_selected)
	var cl = GameState.canvas_layer
	if cl: cl.add_child(_upgrade_panel)
	_upgrade_panel.hide()
