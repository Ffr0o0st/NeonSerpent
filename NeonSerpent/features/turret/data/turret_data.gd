## TurretData — 炮台类型数值资源
class_name TurretData extends Resource

@export var display_name: String = "Turret"
## 每秒伤害
@export var dps: float = 40.0
## 子弹速度（像素/秒）
@export var bullet_speed: float = 600.0
## 射程（格数）
@export var range_cells: int = 5
## 射击间隔（秒）
@export var fire_interval: float = 0.25
## 子弹颜色
@export var bullet_color: Color = Color.YELLOW
## 子弹大小（像素半径）
@export var bullet_size: float = 4.0
## 是否瞬发命中（激光/闪电类）
@export var instant_hit: bool = false
## 子弹穿透数（0=不穿透）
@export var pierce_count: int = 0
