## GridConfig — 网格配置资源
## 定义游戏网格的所有参数，在 Inspector 中可编辑。全局唯一实例保存在 common/resources/。
class_name GridConfig extends Resource

## 网格列数（X 方向）
@export var grid_width: int = 30

## 网格行数（Y 方向）
@export var grid_height: int = 30

## 每格像素尺寸
@export var cell_size: int = 32

## 核心守卫的网格位置
@export var core_position: Vector2i = Vector2i(15, 15)

## 蛇的起始位置
@export var snake_start_position: Vector2i = Vector2i(0, 15)

## 蛇的起始方向
@export var snake_start_direction: Vector2i = Vector2i.RIGHT

## 蛇初始段数
@export var snake_initial_length: int = 3

## 每多少段解锁一个炮台槽位
@export var segments_per_turret_slot: int = 5

## 蛇移动速度（tick/秒）
@export var snake_tick_rate: float = 4.0

## 炮台瘫痪持续时间（秒）
@export var disruption_duration: float = 5.0

## 核心总血量
@export var core_max_hp: int = 200

## 每关回复血量
@export var core_heal_per_level: int = 40

## 食物磁铁吸引半径（格数）
@export var food_magnet_radius: float = 3.0

## 游戏视口像素尺寸
@export var viewport_size: int = 960


## 获取网格边界（最小和最大格坐标）
func get_bounds() -> Dictionary:
	return {
		min = Vector2i.ZERO,
		max = Vector2i(grid_width - 1, grid_height - 1),
	}


## 检查格坐标是否在网格内
func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height
