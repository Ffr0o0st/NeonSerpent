## RelicPanel — 21 遗物 3 选 1 面板（策划案 §4.4）
extends Control

signal relic_selected(relic: Resource)

var _options: Array = []
var _buttons: Array[Button] = []
var _was_pressed: bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	mouse_filter = MOUSE_FILTER_STOP
	hide()
	for i in range(3):
		var btn = get_node_or_null("VBox/Option%d" % (i + 1)) as Button
		if btn: btn.process_mode = PROCESS_MODE_ALWAYS; _buttons.append(btn)


func generate_options() -> void:
	var possible = _build_full_relic_pool()
	possible.shuffle()
	_options.clear()
	for i in range(min(3, possible.size())):
		_options.append(possible[i])
	for i in range(_buttons.size()):
		if i < _options.size():
			var r: Resource = _options[i]
			_buttons[i].text = "[%d] %s\n%s" % [i + 1, r.get("relic_name"), r.get("description")]
			_buttons[i].show()
		else:
			_buttons[i].hide()


func _build_full_relic_pool() -> Array:
	var pool: Array = []
	# === 5 通用遗物 ===
	pool.append(_make("伤害强化", "炮台伤害 +20%", "damage", 0.2))
	pool.append(_make("急速射击", "炮台射击间隔 -25%", "fire_rate", 0.25))
	pool.append(_make("远程瞄准", "炮台射程 +2 格", "range", 2.0))
	pool.append(_make("急速蛇行", "蛇移动速度 +25%", "speed", 0.25))
	pool.append(_make("强磁吸引", "食物磁铁半径 +3 格", "magnet", 3.0))
	# === 6 进化遗物 ===
	pool.append(_make("加特林机枪", "机枪系：射速翻倍", "evo_machinegun", 2.0))
	pool.append(_make("重型迫击炮", "迫击炮系：爆炸半径 +50%", "evo_mortar", 1.5))
	pool.append(_make("超频激光", "激光系：穿透伤害 +50%", "evo_laser", 1.5))
	pool.append(_make("深冻射线", "冰冻系：减速增强至 50%", "evo_ice", 0.5))
	pool.append(_make("地狱火", "火焰系：射程 +2 伤害 +30%", "evo_flame", 1.3))
	pool.append(_make("雷暴", "闪电系：弹射次数 +3", "evo_lightning", 3.0))
	# === 3 融合遗物 ===
	pool.append(_make("霜冻机枪", "机枪+冰冻：DPS+减速", "fusion_mg_ice", 1.0))
	pool.append(_make("燃烧迫击炮", "迫击炮+火焰：范围燃烧", "fusion_mortar_flame", 1.0))
	pool.append(_make("电弧激光", "激光+闪电：穿透+弹射", "fusion_laser_lightning", 1.0))
	# === 4 蛇身遗物 ===
	pool.append(_make("弹性蛇身", "自碰检测跳过 2 段", "body_elastic", 2.0))
	pool.append(_make("加速生长", "成长所需食物 -1", "body_growth", 1.0))
	pool.append(_make("护体鳞片", "瘫痪时间 -2s", "body_armor", -2.0))
	pool.append(_make("长蛇基因", "初始蛇长 +2", "body_longer", 2.0))
	# === 3 特殊遗物 ===
	pool.append(_make("过热模式", "连杀 15→全炮台 5s 射速翻倍", "special_overheat", 1.0))
	pool.append(_make("核心护盾", "核心每关 1 次 2s 无敌", "special_shield", 2.0))
	pool.append(_make("食物暴击", "20% 几率食物掉落翻倍", "special_double_food", 0.2))
	return pool


func _make(name: String, desc: String, etype: String, val: float) -> Resource:
	var td_script: Script = load("res://features/relic/data/relic_data.gd") as Script
	var r: Resource = td_script.new()
	r.set("relic_name", name); r.set("description", desc)
	r.set("effect_type", etype); r.set("effect_value", val)
	return r


func _process(_delta: float) -> void:
	if not visible: return
	var pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if pressed and not _was_pressed:
		var pos: Vector2 = get_global_mouse_position()
		for i in range(_buttons.size()):
			if not _buttons[i].visible: continue
			if _buttons[i].get_global_rect().has_point(pos): _confirm(i); return
	_was_pressed = pressed


func _input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed(&"upgrade_slot_1"): _confirm(0)
	elif event.is_action_pressed(&"upgrade_slot_2"): _confirm(1)
	elif event.is_action_pressed(&"upgrade_slot_3"): _confirm(2)


func _confirm(index: int) -> void:
	if index < 0 or index >= _options.size(): return
	hide()
	get_tree().paused = false
	relic_selected.emit(_options[index])
