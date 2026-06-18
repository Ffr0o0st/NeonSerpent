## MainMenu — 主菜单
extends Control


func _ready() -> void:
	var start_btn = $VBox/StartBtn as Button
	if start_btn:
		start_btn.pressed.connect(_on_start)
	var quit_btn = $VBox/QuitBtn as Button
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)


func _on_start() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://levels/level_base.tscn")


func _on_quit() -> void:
	get_tree().quit()
