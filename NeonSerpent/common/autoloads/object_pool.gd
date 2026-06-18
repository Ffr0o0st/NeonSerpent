## ObjectPool — 对象池（Autoload 单例）
## 预创建并复用频繁生成/销毁的节点（敌人、子弹、食物、VFX），避免 GC 波动。
## 使用方式：ObjectPool.acquire("res://path/to/scene.tscn")
extends Node

## 对象池存储：{场景路径: [已停用的节点数组]}
var _pool: Dictionary = {}  # Dictionary[StringName, Array[Node]]

## 各类型池的容量配置
var _pool_sizes: Dictionary = {
	&"enemies": 50,
	&"projectiles": 100,
	&"food_items": 30,
	&"vfx": 20,
}


## 预热对象池——在加载或波次倒计时期间调用，将实例化分散到多帧以避免卡顿
func prewarm(scene_path: String, count: int, pool_key: StringName = &"") -> void:
	var key: StringName = pool_key if pool_key else _path_to_key(scene_path)
	if not _pool.has(key):
		_pool[key] = []
	for _i in range(count):
		_create_and_store(scene_path, key)


## 从池中获取一个已激活的节点
func acquire(scene_path: String, pool_key: StringName = &"") -> Node:
	var key: StringName = pool_key if pool_key else _path_to_key(scene_path)
	# 确保 key 存在
	if not _pool.has(key):
		_pool[key] = []
	# 尝试从池中取出现有节点
	var pool_array: Array = _pool[key]
	for node in pool_array:
		if not node.is_inside_tree() or not node.is_processing():
			pool_array.erase(node)
			_activate_node(node)
			return node
	# 池为空，实例化新的
	return _create_and_activate(scene_path, key)


## 将节点归还给池（停用但保留在内存中）
func release(node: Node, pool_key: StringName = &"") -> void:
	var key: StringName = pool_key
	if key == &"":
		# 尝试从已有池中找到匹配的 key
		for k in _pool:
			if node in _pool[k]:
				key = k
				break
		if key == &"":
			key = &"generic"
	if not _pool.has(key):
		_pool[key] = []
	_deactivate_node(node)
	if node not in _pool[key]:
		_pool[key].append(node)


## 清空指定池（场景切换时）
func clear_pool(pool_key: StringName = &"") -> void:
	if pool_key == &"":
		for key in _pool.keys():
			_clear_pool_array(_pool[key])
		_pool.clear()
	else:
		if _pool.has(pool_key):
			_clear_pool_array(_pool[pool_key])
			_pool.erase(pool_key)


# === 内部方法 ===


## 创建新节点并加入池中（停用状态）
func _create_and_store(scene_path: String, pool_key: StringName) -> void:
	var scene: PackedScene = load(scene_path) as PackedScene
	if not scene:
		push_error("[ObjectPool] 无法加载场景: ", scene_path)
		return
	var instance = scene.instantiate()
	_deactivate_node(instance)
	_pool[pool_key].append(instance)


## 创建新节点并立即激活
func _create_and_activate(scene_path: String, pool_key: StringName) -> Node:
	var scene: PackedScene = load(scene_path) as PackedScene
	if not scene:
		push_error("[ObjectPool] 无法加载场景: ", scene_path)
		return null
	var instance = scene.instantiate()
	_activate_node(instance)
	return instance


## 激活节点
func _activate_node(node: Node) -> void:
	if node is Node2D:
		node.show()
	if node is CollisionObject2D:
		node.set_deferred(&"disabled", false)
	node.set_process(true)
	node.set_physics_process(true)


## 停用节点
func _deactivate_node(node: Node) -> void:
	if node is Node2D:
		node.hide()
	if node is CollisionObject2D:
		# 移除碰撞体以防止与活跃对象交互
		if node.is_inside_tree():
			node.set_deferred(&"disabled", true)
		else:
			(node as CollisionObject2D).disabled = true
	node.set_process(false)
	node.set_physics_process(false)
	# 从场景树中移除但不释放
	if node.get_parent():
		node.get_parent().remove_child(node)


## 清空池数组（释放所有节点）
func _clear_pool_array(pool_array: Array) -> void:
	for node in pool_array:
		if node and is_instance_valid(node):
			node.queue_free()
	pool_array.clear()


## 从场景路径提取池 key（如 "res://features/enemy/enemy_crawler.tscn" → "enemy_crawler"）
func _path_to_key(scene_path: String) -> StringName:
	var file_name: String = scene_path.get_file().trim_suffix(".tscn").trim_suffix(".scn")
	return StringName(file_name)
