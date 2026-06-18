## WaveClearText — 波次清除霓虹大字（Control 版本，添加到 CanvasLayer）
extends Label

func _ready() -> void:
	hide()
	horizontal_alignment = 1  # HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = 1    # VERTICAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 48)
	add_theme_color_override("font_color", Color("#00FFFF"))
	text = ""
	EventBus.wave_cleared.connect(_on_wave_cleared)


func _on_wave_cleared(_wave_index: int) -> void:
	text = "波次清除"
	modulate = Color(0.4, 1.0, 1.0, 1.0)  # 更亮的霓虹青
	scale = Vector2(0.3, 0.3)
	show()
	var tw = get_tree().create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(self, "modulate:a", 0.0, 1.2).set_delay(0.4)
	tw.chain().tween_callback(hide)
