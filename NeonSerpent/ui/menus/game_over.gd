## GameOver 面板
extends Control

signal restart()

@onready var _reason_label: Label = $Reason
@onready var _stats_label: Label = $Stats


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	mouse_filter = MOUSE_FILTER_STOP
	hide()
	var btn = $RestartBtn as Button
	if btn:
		btn.process_mode = PROCESS_MODE_ALWAYS
		btn.pressed.connect(_on_restart)


func set_reason(reason: String) -> void:
	if _reason_label:
		_reason_label.text = reason
	if _stats_label:
		_stats_label.text = "蛇长: %d  击杀: %d  波次: %d" % [
			GameState.snake_length,
			GameState.kill_count,
			GameState.current_wave,
		]


func _on_restart() -> void:
	restart.emit()
