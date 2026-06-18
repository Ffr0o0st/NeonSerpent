## AudioManager — 音频管理（Autoload 单例，桩实现）
## 负责音乐播放和音效触发。目前为桩，后续集成实际音频资源。
extends Node

# === 音频总线 ===

## 主音量（0.0 - 1.0）
var master_volume: float = 1.0:
	set(v):
		master_volume = clampf(v, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"), linear_to_db(master_volume))

## 音乐音量
var music_volume: float = 0.8:
	set(v):
		music_volume = clampf(v, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(music_volume))

## 音效音量
var sfx_volume: float = 1.0:
	set(v):
		sfx_volume = clampf(v, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), linear_to_db(sfx_volume))

# === 内部引用 ===

## 当前正在播放的音乐播放器
var _music_player: AudioStreamPlayer
## 音效播放器池
var _sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_setup_audio_buses()
	_create_music_player()


## 设置音频总线（Master / Music / SFX）
func _setup_audio_buses() -> void:
	# 如果总线不存在则创建
	var bus_count = AudioServer.bus_count
	var has_music = false
	var has_sfx = false
	for i in bus_count:
		var bus_name = AudioServer.get_bus_name(i)
		if bus_name == &"Music":
			has_music = true
		if bus_name == &"SFX":
			has_sfx = true

	if not has_music:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, &"Music")
	if not has_sfx:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, &"SFX")


## 创建音乐播放器节点
func _create_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)


## 播放背景音乐
func play_music(stream: AudioStream) -> void:
	if not _music_player:
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()


## 停止背景音乐
func stop_music() -> void:
	if _music_player:
		_music_player.stop()


## 播放一次性音效
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	var player = _get_free_sfx_player()
	if not player:
		return
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


## 获取一个空闲的音效播放器
func _get_free_sfx_player() -> AudioStreamPlayer:
	# 先找已经空闲的
	for player in _sfx_players:
		if not player.playing:
			return player
	# 创建新的（最多 8 个）
	if _sfx_players.size() < 8:
		var new_player = AudioStreamPlayer.new()
		new_player.bus = &"SFX"
		new_player.finished.connect(_on_sfx_finished.bind(new_player))
		add_child(new_player)
		_sfx_players.append(new_player)
		return new_player
	# 全部忙，返回最旧的（停止它并复用）
	var oldest = _sfx_players[0]
	oldest.stop()
	return oldest


## SFX 播放完毕回调
func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	pass  # 玩家回到可用池
