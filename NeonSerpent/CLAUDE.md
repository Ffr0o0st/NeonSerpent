# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**蛇卫核心 (Neon Serpent)** — 贪吃蛇 × 吸血鬼幸存者 × 塔防 mashup，赛博霓虹视觉风格。
Godot 4.6 项目，GL Compatibility 渲染器，GDScript。

## 常用命令

```bash
# 启动游戏（Godot 编辑器打开项目，F5）
# 无命令行构建——所有测试通过 Godot MCP (@satelliteoflove/godot-mcp) 在运行时进行
```

## 核心架构

### 网格与视口
- **24×24 网格**，每格 32px，视口 768×768，窗口可缩放（stretch mode=canvas_items, expand）
- `GridUtils` 静态类：`cell_to_world()` / `world_to_cell()`，**严禁手写坐标换算**
- `GridConfig`（`.tres`）：核心 (12,12)，蛇起始 (0,12)，蛇长 2

### Autoload 单例
| 单例 | 职责 |
|------|------|
| `EventBus` | 10 个信号，跨系统解耦（已清理 5 个死信号） |
| `GameState` | 运行时状态 + `cached_enemies` + 全局引用缓存 |
| `ObjectPool` | 对象池（有限使用） |
| `AudioManager` | 音频管理 |
| `MCPGameBridge` | MCP 测试桥接 |

### GameState 全局引用（消除场景树遍历）
- `relic_manager` — RelicManager._ready() 注册
- `canvas_layer` — LevelBase._setup_hud() 注册
- `snake_head` — SnakeHead._ready() 注册
- `snake_manager` — SnakeManager._ready() 注册
- **所有组件直接读 GameState，不再用 `get_first_node_in_group("level_base")`**

### 蛇系统
- **SnakeHead**：离散 tick 移动（4 tick/s），输入缓冲，180° 反转
  - 使用 Sprite2D（`snake_head.png`）+ rotation 朝向，目标宽度 40px
- **SnakeManager**：管理身体段节点池，增长成本 3→4→5→6→7。每 3 段触发炮台升级
- **SnakeBodySegment**：Sprite2D 优先（`snake_body.png`，宽度=1格32px），`_draw()` 为 fallback

### 炮台系统（24×24 地图，射程统一 6 格，interval×2）
| 类型 | DPS | 射程 | 间隔 | 单发 | 特殊 |
|------|-----|------|------|------|------|
| machinegun | 40 | 6 | 0.5s | 20 | 基础弹道 |
| mortar | 15 | 6 | 2.0s | 30 | 96px 溅射 + 爆炸光圈 |
| laser | 48 | 6 | 1.0s | 48 | 瞬发穿透线 |
| ice | 15 | 6 | 1.0s | 15 | 减速 30% ×3s |
| flame | 60 | 6 | 0.3s | 18 | 持续灼烧 |
| lightning | 28 | 6 | 1.2s | 33.6 | 连锁弹射 3 次 |

蛇头自带蛇头炮台（TurretManager 创建，`snake_turret.png`，0.7x 缩放）。

### 敌人系统
- 7 种敌人，全部 `.gd` + `.tscn` + `.tres`，数据完全由 `.tres` 驱动，**无硬编码兜底**
- **移速标准化**：按生成点到核心距离等比缩放（角落全速、边中点 ~70%），统一到达时间
- 受击闪白：`modulate = Color(5,5,5,1)` → tween 回 `pre_flash`（保留减速蓝调）
- 冰冻减速：3s 计时器，到期恢复原速

### VFX 系统
| 效果 | 文件 | 说明 |
|------|------|------|
| 死亡粒子 | `vfx/death_particles.gd` | 14 粒子 + 扩散光圈，匹配敌人颜色 |
| 爆炸光圈 | `vfx/explosion_ring.gd` | 自包含 Node2D，扩大+淡出+自毁 |
| 子弹拖尾 | `projectile_base.gd` | 8 帧历史位置，alpha 0.7 |
| 受击闪白 | `enemy_base.gd` | modulate 5x 过曝 |
| 波次清除 | `vfx/wave_clear_text.gd` | 弹性 scale + 淡出 |
| 食物收集 | `food_item.gd` | 4 绿色火花粒子 |

### 波次/关卡
- 5 关 × 1-2 波，全部 `.tres`，`GameFlowManager` 状态机统一管理

## 关键约束

- **Tween**：始终用 `get_tree().create_tween()`，不用 `create_tween()`
- **Hot path**：禁止 `load()` → 用 `preload`；禁止 `get_nodes_in_group()` → 用 `GameState.cached_enemies`
- **缩进**：类体 0 缩进，函数体 1 tab。sed 编辑后必须 `cat -A` 验证
- **@onready** 必须在单独一行，不能与 `var` 同行
- **Sprite 检测**：检查 `_sprite.texture`（节点已加载），而非 `texture`（@export 变量可能为 null）

## 策划案偏差（已确认）
- 炮台间隔 3 段（非 5）、初始蛇长 2（非 3+机枪）、瘫痪 5s（非 10s）

## 美术资源
`assets/sprites/README.md` — 35 项资源规格，平台无关 AI 提示词（nano banana 2 等通用）

## 项目记忆
`memory/` 目录含开发经验记录（Godot 错误、编码规则等 6 个文件）
