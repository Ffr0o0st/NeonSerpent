## FoodSpawner — 食物生成器（关卡级）
## 监听 EventBus.enemy_killed 信号，在敌人死亡位置生成对应数量的食物。
class_name FoodSpawner extends Node

## 食物场景
var _food_scene: PackedScene = preload("res://features/food/food_item.tscn")

## 食物容器
var _food_container: Node2D


func _ready() -> void:
	# 创建或查找食物容器
	var parent = get_parent()
	if parent and parent.has_node("FoodItems"):
		_food_container = parent.get_node("FoodItems") as Node2D
	else:
		_food_container = Node2D.new()
		_food_container.name = "FoodItems"
		if parent:
			parent.add_child(_food_container)
		else:
			add_child(_food_container)

	EventBus.enemy_killed.connect(_on_enemy_killed)


func _on_enemy_killed(_enemy_type: String, position: Vector2, food_count: int) -> void:
	for i in range(food_count):
		var food = _food_scene.instantiate() as FoodItem
		# 微小的位置偏移，避免食物堆叠
		var offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		food.position = position + offset
		_food_container.add_child(food)
