## GridUtils — 网格坐标转换工具类（静态方法）
## 统一处理格坐标 ↔ 世界像素坐标的转换。禁止在其它脚本中手写坐标换算。
class_name GridUtils

# GridConfig 引用（由关卡场景在 _ready 时设置）
static var config: GridConfig


## 设置网格配置（在关卡场景 _ready() 中调用一次）
static func setup(grid_config: GridConfig) -> void:
	config = grid_config


## 格坐标 → 世界像素坐标（格中心点）
## (0,0) = 左上角，(29,29) = 右下角
static func cell_to_world(cell: Vector2i) -> Vector2:
	if not config:
		push_error("[GridUtils] 未设置 GridConfig，请先调用 GridUtils.setup()")
		return Vector2.ZERO
	# 格中心 = (列 + 0.5) * 格尺寸
	return Vector2(
		(cell.x + 0.5) * config.cell_size,
		(cell.y + 0.5) * config.cell_size
	)


## 世界像素坐标 → 格坐标
static func world_to_cell(world_pos: Vector2) -> Vector2i:
	if not config:
		push_error("[GridUtils] 未设置 GridConfig，请先调用 GridUtils.setup()")
		return Vector2i.ZERO
	var cell_x = int(clampf(floor(world_pos.x / config.cell_size), 0.0, float(config.grid_width - 1)))
	var cell_y = int(clampf(floor(world_pos.y / config.cell_size), 0.0, float(config.grid_height - 1)))
	return Vector2i(cell_x, cell_y)


## 格坐标 → 世界像素坐标（格左上角）
static func cell_to_world_top_left(cell: Vector2i) -> Vector2:
	if not config:
		return Vector2.ZERO
	return Vector2(cell.x * config.cell_size, cell.y * config.cell_size)


## 获取网格的像素范围（左上角和右下角的世界坐标）
static func get_world_bounds() -> Dictionary:
	if not config:
		return {top_left = Vector2.ZERO, bottom_right = Vector2.ZERO}
	return {
		top_left = Vector2.ZERO,
		bottom_right = Vector2(config.grid_width * config.cell_size, config.grid_height * config.cell_size),
	}
