## GridOverlay — 在屏幕上绘制 30×30 网格线
## 使用 _draw() 直接绘制暗霓虹蓝网格线，无需额外节点。
class_name GridOverlay extends Node2D

## 网格线颜色（暗霓虹蓝）
@export var line_color: Color = Color("#1A1A3E")
## 网格线透明度
@export var line_alpha: float = 0.3


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if not GridUtils.config:
		return

	var bounds: Dictionary = GridUtils.get_world_bounds()
	var bottom_right: Vector2 = bounds.bottom_right
	var cell_size: int = GridUtils.config.cell_size
	var grid_w: int = GridUtils.config.grid_width
	var grid_h: int = GridUtils.config.grid_height

	var draw_color = Color(line_color, line_alpha)

	# 绘制竖线（X 方向）
	for x in range(grid_w + 1):
		var from_pos = Vector2(x * cell_size, 0)
		var to_pos = Vector2(x * cell_size, bottom_right.y)
		draw_line(from_pos, to_pos, draw_color, 1.0)

	# 绘制横线（Y 方向）
	for y in range(grid_h + 1):
		var from_pos = Vector2(0, y * cell_size)
		var to_pos = Vector2(bottom_right.x, y * cell_size)
		draw_line(from_pos, to_pos, draw_color, 1.0)

	# 在核心位置绘制标记（暗白金小十字）
	var core_world = GridUtils.cell_to_world(GridUtils.config.core_position)
	var marker_color = Color("#FFD700", 0.15)
	var marker_size: float = cell_size * 0.3
	draw_line(
		core_world + Vector2(-marker_size, 0),
		core_world + Vector2(marker_size, 0),
		marker_color, 1.0
	)
	draw_line(
		core_world + Vector2(0, -marker_size),
		core_world + Vector2(0, marker_size),
		marker_color, 1.0
	)
	# 核心位置小圆
	draw_circle(core_world, marker_size * 0.5, marker_color)
