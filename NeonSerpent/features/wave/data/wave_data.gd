## WaveData — 单个波次的配置资源
class_name WaveData extends Resource

@export var wave_name: String = "Wave 1"
## 预估时长（秒），用于 UI 和超时兜底
@export var duration_estimate: float = 35.0
## 敌人场景路径列表
@export var enemy_scene_paths: Array[String] = []
## 每组敌人数量（与 scene_paths 一一对应）
@export var enemy_counts: Array[int] = []
## 每组生成间隔（秒）
@export var spawn_intervals: Array[float] = []
## 每组开始前延迟（秒）
@export var start_delays: Array[float] = []
