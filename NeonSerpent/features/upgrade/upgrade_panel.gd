## UpgradePanel — 升级 3 选 1 面板（_process 轮询鼠标，tree paused 时仍有效）
extends Control

signal option_selected(turret_type: String)

var _options: Array = []
var _buttons: Array[Button] = []
var _was_pressed: bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	mouse_filter = MOUSE_FILTER_STOP
	hide()
	for i in range(3):
		var btn = get_node_or_null("VBox/Option%d" % (i + 1)) as Button
		if btn:
			btn.process_mode = PROCESS_MODE_ALWAYS
			_buttons.append(btn)


func set_options(options: Array) -> void:
	_options = options
	for i in range(_buttons.size()):
		if i < options.size():
			_buttons[i].text = "[%d] %s 炮台" % [i + 1, options[i]]
			_buttons[i].show()
		else:
			_buttons[i].hide()


func _process(_delta: float) -> void:
	if not visible: return
	# 鼠标左键——_process 在 PROCESS_MODE_ALWAYS 下暂停时仍运行
	var pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if pressed and not _was_pressed:
		var pos: Vector2 = get_global_mouse_position()
		for i in range(_buttons.size()):
			if not _buttons[i].visible: continue
			if _buttons[i].get_global_rect().has_point(pos):
				_confirm(i)
				return
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
	option_selected.emit(_options[index])
