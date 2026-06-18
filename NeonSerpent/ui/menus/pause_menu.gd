## Pause 暂停菜单
extends Control


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	mouse_filter = MOUSE_FILTER_STOP
	hide()
	var resume_btn = $VBox/ResumeBtn as Button
	if resume_btn:
		resume_btn.process_mode = PROCESS_MODE_ALWAYS
		resume_btn.pressed.connect(_on_resume)
	var restart_btn = $VBox/RestartBtn as Button
	if restart_btn:
		restart_btn.process_mode = PROCESS_MODE_ALWAYS
		restart_btn.pressed.connect(_on_restart)
	var quit_btn = $VBox/QuitBtn as Button
	if quit_btn:
		quit_btn.process_mode = PROCESS_MODE_ALWAYS
		quit_btn.pressed.connect(_on_quit)


func _on_resume() -> void:
	hide()
	get_tree().paused = false
	EventBus.game_resumed.emit()


func _on_restart() -> void:
	get_tree().paused = false
	GameState.reset()
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/menus/main_menu.tscn")
