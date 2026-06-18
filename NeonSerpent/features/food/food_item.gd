## FoodItem — 食物掉落物
class_name FoodItem extends Node2D

@export var texture: Texture2D = null
@export var magnet_radius: float = 3.0
@export var attract_speed: float = 200.0
@export var pop_speed: float = 80.0
@export var food_color: Color = Color("#00FF66")
@export var food_size: float = 8.0

var _sprite: Sprite2D = null
var _has_sprite: bool = false
var _snake_head: SnakeHead
var _velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 99999.0  # 永不过期
var _magnet_radius_px: float = 0.0
var _attract_speed: float = 200.0


func _ready() -> void:
	_sprite = $Sprite
	if _sprite.texture:
		_sprite.show()
		_has_sprite = true
	else:
		_sprite.hide()

	_magnet_radius_px = magnet_radius * GridUtils.config.cell_size
	_velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * pop_speed

	_snake_head = GameState.snake_head as SnakeHead
	var rm = GameState.relic_manager
	if rm and rm.has_method("get_magnet_bonus"):
		_magnet_radius_px += rm.call("get_magnet_bonus") * GridUtils.config.cell_size

	if _snake_head and GridUtils.config:
		_attract_speed = attract_speed


func _process(delta: float) -> void:
	if get_tree().paused: return

	# 食物永不过期，等待被蛇头收集

	if _snake_head and is_instance_valid(_snake_head):
		var dist = position.distance_to(_snake_head.position)
		if dist < 8.0:
			_collect(); return
		elif dist < _magnet_radius_px:
			var to_head = (_snake_head.position - position).normalized()
			_velocity = to_head * _attract_speed
		else:
			_velocity = _velocity.lerp(Vector2.ZERO, delta * 2.0)
	else:
		_velocity = _velocity.lerp(Vector2.ZERO, delta * 2.0)

	position += _velocity * delta
	if not _has_sprite:
		queue_redraw()


func _draw() -> void:
	if _has_sprite: return
	var hs = food_size / 2.0
	draw_rect(Rect2(-hs, -hs, food_size, food_size), food_color)
	draw_rect(Rect2(-hs - 2, -hs - 2, food_size + 4, food_size + 4), Color(food_color, 0.3), false, 1.0)


func _collect() -> void:
	# 收集瞬间亮绿粒子爆发
	var tree = get_tree()
	if not tree: return
	var parent = get_parent()
	if parent:
		for i in range(4):
			var spark = Node2D.new()
			var angle = TAU * i / 4.0
			spark.position = position
			parent.add_child(spark)
			var tw = tree.create_tween()
			var end_pos = position + Vector2.RIGHT.rotated(angle) * 24.0
			tw.tween_property(spark, "position", end_pos, 0.25)
			tw.parallel().tween_property(spark, "modulate:a", 0.0, 0.25)
			tw.tween_callback(spark.queue_free)
			# 手动绘制绿色圆点
			spark.draw_circle(Vector2.ZERO, 3.0, Color.GREEN)
	EventBus.food_collected.emit(1)
	queue_free()
