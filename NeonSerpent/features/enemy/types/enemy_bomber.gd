## EnemyBomber — 自爆虫：橙红闪烁，死爆3格瘫痪5s
## 策划案：HP 60→120, 移速 1.3, 核伤 3, 食物 2, 死爆3格瘫痪5s
class_name EnemyBomber extends EnemyBase

var _flicker_timer: float = 0.0


func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_flicker_timer += delta
	queue_redraw()


func _die() -> void:
	var snake_mgr = GameState.snake_manager
	if snake_mgr and snake_mgr.has_method("mark_segment_disrupted"):
		# 瘫痪周围3格内的蛇身段
		for i in range(GameState.snake_body_cells.size()):
			var body_cell: Vector2i = GameState.snake_body_cells[i]
			var world_pos: Vector2 = GridUtils.cell_to_world(body_cell)
			if position.distance_to(world_pos) < GridUtils.config.cell_size * 3.5:
				snake_mgr.mark_segment_disrupted(i)
	super._die()


func _draw() -> void:
	super._draw()
	# 橙红闪烁
	var flicker: float = abs(sin(_flicker_timer * 10.0))
	var s: float = (enemy_data.visual_size if enemy_data else 28.0) / 2.0
	draw_circle(Vector2.ZERO, s * 1.3, Color(1.0, 0.27, 0.0, flicker * 0.5))
