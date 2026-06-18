## Victory 面板
extends Control

signal restart()


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	mouse_filter = MOUSE_FILTER_STOP
	hide()
	var btn = $VBox/RestartBtn as Button
	if btn:
		btn.process_mode = PROCESS_MODE_ALWAYS
		btn.pressed.connect(_on_restart)


func _on_restart() -> void:
	restart.emit()
