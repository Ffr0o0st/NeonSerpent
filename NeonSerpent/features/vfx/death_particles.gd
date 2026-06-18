## DeathParticles — 敌人死亡粒子效果（增强版）
## 14 粒子 + 扩散冲击波光圈 + 敌人真实颜色匹配
extends Node2D

var _particles: Array = []  # [{pos, vel, color, lifetime, max_life}]
var _rings: Array = []      # [{pos, color, lifetime, max_life}] 扩散光圈

const PARTICLE_COUNT: int = 14
const MAX_LIFE: float = 0.7
const SPREAD_SPEED: float = 180.0
const RING_MAX_RADIUS: float = 80.0
const RING_LIFE: float = 0.35

# 类型→颜色映射（策划案 §3.2）
const COLOR_MAP: Dictionary = {
	"Crawler": Color("#FF6600"),
	"Runner": Color("#FFDD00"),
	"Heavy": Color("#CC0000"),
	"Disruptor": Color("#CC00FF"),
	"Bomber": Color("#FF4400"),
	"Behemoth": Color("#FF0000"),
	"Mirror": Color("#9900CC"),
}


func _ready() -> void:
	EventBus.enemy_killed.connect(_on_enemy_killed)
	hide()
	set_process(false)


func _on_enemy_killed(type: String, pos: Vector2, _food: int) -> void:
	var c: Color = COLOR_MAP.get(type, Color("#FF6600"))
	for i in range(PARTICLE_COUNT):
		var angle: float = TAU * i / PARTICLE_COUNT + randf_range(-0.3, 0.3)
		var spd: float = SPREAD_SPEED * randf_range(0.4, 1.6)
		_particles.append({
			pos = pos,
			vel = Vector2.RIGHT.rotated(angle) * spd,
			color = c,
			lifetime = MAX_LIFE * randf_range(0.4, 1.0),
			max_life = MAX_LIFE,
		})
	# 扩散冲击波光圈
	_rings.append({pos = pos, color = c, lifetime = RING_LIFE, max_life = RING_LIFE})
	show()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var all_dead: bool = true
	for p in _particles:
		p.lifetime -= delta
		if p.lifetime > 0:
			all_dead = false
			p.pos += p.vel * delta
			p.vel *= 0.93  # 阻力
	for r in _rings:
		r.lifetime -= delta
		if r.lifetime > 0:
			all_dead = false
	if all_dead:
		_particles.clear()
		_rings.clear()
		set_process(false)
		hide()
	queue_redraw()


func _draw() -> void:
	# 绘制扩散光圈
	for r in _rings:
		if r.lifetime <= 0: continue
		var ratio: float = 1.0 - r.lifetime / r.max_life  # 0→1
		var radius: float = RING_MAX_RADIUS * ratio
		var alpha: float = 1.0 - ratio
		draw_circle(r.pos - position, radius, Color(r.color, alpha * 0.5), false, 2.0)
	# 绘制粒子
	for p in _particles:
		if p.lifetime <= 0: continue
		var ratio: float = p.lifetime / p.max_life
		var size: float = lerpf(2.0, 8.0, ratio)
		var alpha: float = ratio
		draw_circle(p.pos - position, size, Color(p.color, alpha))
