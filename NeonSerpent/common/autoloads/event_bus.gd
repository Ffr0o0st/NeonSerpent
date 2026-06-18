## EventBus — 全局信号总线（Autoload 单例）
## 仅用于跨系统的生命周期事件，数量控制在 15 个以内。
## 使用方式：EventBus.wave_started.emit()
extends Node

# === 关卡与波次生命周期 ===

## 新波次开始（参数：wave_index: int）
signal wave_started(wave_index: int)
## 当前波次清除（参数：wave_index: int）
signal wave_cleared(wave_index: int)
## 关卡完成（参数：level_index: int）
signal level_completed(level_index: int)

# === 玩家与核心 ===

## 玩家蛇头死亡
signal player_died()
## 核心受到伤害（参数：current_hp: int, max_hp: int）
signal core_damaged(current_hp: int, max_hp: int)
## 核心被摧毁
signal core_destroyed()

# === 战斗反馈 ===

## 敌人被击杀（参数：enemy_type: String, position: Vector2, food_count: int）
signal enemy_killed(enemy_type: String, position: Vector2, food_count: int)
## 食物被收集（参数：amount: int）
signal food_collected(amount: int)

# === UI 事件 ===

# === 游戏流程 ===

## 游戏暂停
signal game_paused()
## 游戏继续
signal game_resumed()
