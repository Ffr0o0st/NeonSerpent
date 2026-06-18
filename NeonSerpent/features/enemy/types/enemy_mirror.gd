## EnemyMirror — 镜像蛇：最终Boss，回放玩家移动历史，每20s+1段
## 策划案：HP 800→1600, 移速 1.0, 核伤 5, 食物 0, 暗紫半透明, 每20s+1段
class_name EnemyMirror extends EnemyBase

var _position_history: Array = []  # 回放缓冲
var _playback_index: int = 0
var _growth_timer: float = 0.0
var _mirror_segments: int = 3
var _record_interval: float = 0.25  # 记录间隔 = 1 tick


func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	if get_tree().paused: return

	# 记录蛇头位置
	_growth_timer += delta
	if _growth_timer >= 20.0:
		_growth_timer = 0.0
		_mirror_segments += 1

	if _snake_head_ref and is_instance_valid(_snake_head_ref):
		_position_history.append(_snake_head_ref.position)
		# 限制缓冲大小
		while _position_history.size() > 600:  # ~30秒
			_position_history.pop_front()

	# 回放历史位置
	if _position_history.size() > _mirror_segments * 4:
		_playback_index += 1
		if _playback_index >= _position_history.size():
			_playback_index = 0
		position = _position_history[_playback_index]

	queue_redraw()


func _draw() -> void:
	super._draw()
	# 绘制镜像蛇身段（从历史位置推算）
	var c: Color = Color("#9900CC", 0.5)
	for i in range(1, _mirror_segments + 1):
		var hist_idx: int = _playback_index - i * 4
		if hist_idx >= 0 and hist_idx < _position_history.size():
			var seg_pos: Vector2 = _position_history[hist_idx]
			var local_pos: Vector2 = seg_pos - position
			if local_pos.length() < 200:
				draw_circle(local_pos, 10.0, c)
