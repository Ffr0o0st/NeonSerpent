---
name: godot-errors
description: Godot 4 GDScript 常见编译/运行时错误原因和修复方法
metadata: 
  node_type: memory
  type: project
  originSessionId: 92087abd-a1d7-4a9c-97d6-124c5b504f60
---

# Godot 4 常见错误记录

## 1. class_name 加载顺序导致 "Could not find base class"

**错误**：`Parser Error: Could not find base class "TurretBase"`

**原因**：Godot 4 按字母顺序编译脚本。当脚本 A 使用 `extends SomeClass` 而 `SomeClass` 定义在另一个文件中时，如果 `SomeClass` 的脚本编译失败或尚未注册为全局 class_name，则 A 编译失败。手写 `.tscn` 文件时尤其容易触发。

**修复**：所有新炮台/实体脚本 **不继承自定义 class_name 基类**，改为 `extends Node2D`，将基类逻辑自包含到子类中。使用 `turret_data: Resource` + `set()/get()` 动态传递配置数据。

```gdscript
# ❌ 错误
class_name TurretMortar extends TurretBase

# ✅ 正确
extends Node2D
@export var turret_data: Resource = null
```

## 2. 重复声明常量/变量

**错误**：`Constant "_projectile_scene" has the same name as a previously declared constant`

**原因**：编辑时追加了已有声明，导致同一作用域内两个同名 `const`。

**修复**：修改前先 `grep` 检查目标字符串是否已存在。

## 3. 同一作用域重复声明 var

**错误**：`There is already a variable named "tree" declared in this scope`

**原因**：同一函数内两次 `var tree = get_tree()`，合并为一次声明。

## 4. := 类型推断在严格模式下报错

**错误**：`The variable type is being inferred from a Variant value. (Warning treated as error.)`

**修复**：在 `project.godot` 添加 `[debug] gdscript/warnings/untyped_declaration=1` 将警告降级。或改为显式类型 `var x: Type = value`。

## 5. Control 枚举常量在 extends Label 脚本中报未声明

**错误**：`Identifier "HORIZONTAL_CENTER" not declared in the current scope`

**原因**：`extends Label` 脚本中直接使用 `HORIZONTAL_CENTER` 时，Godot 4 的 GDScript 编译器在某些编译路径下不会自动从 `Control` 基类继承枚举常量。全称是 `Control.HORIZONTAL_ALIGNMENT_CENTER`。

**修复**：使用整数值代替（`horizontal_alignment = 1` 表示居中，`vertical_alignment = 1`），或使用完整路径 `Control.HORIZONTAL_ALIGNMENT_CENTER`。

## 6. 局部变量跨函数引用：evo_mult not declared in scope

**错误**：`Identifier "evo_mult" not declared in the current scope`

**原因**：`_fire()` 方法内部定义的局部变量 `evo_mult`，在调用 `_spawn_projectile()` 和 `_chain_damage()` 时，这些子函数内部需要用到该值，但**未作为参数传入**。GDScript 没有闭包捕获外部局部变量的机制。

**修复**：将 `evo_mult` 作为参数添加到 `_spawn_projectile()` 和 `_chain_damage()` 的函数签名中（带默认值 `1.0`），并在所有调用点显式传入。

```gdscript
# ❌ 错误
func _fire(cfg):  # evo_mult 在此定义但子函数看不到
    var evo_mult = ...
    _spawn_projectile(ptype, color, cfg, target)  # 内部报错

func _spawn_projectile(ptype, color, cfg, target):
    cfg.dps * cfg.interval * evo_mult  # 报错!

# ✅ 正确
func _fire(cfg):
    var evo_mult = ...
    _spawn_projectile(ptype, color, cfg, target, evo_mult)  # 显式传入

func _spawn_projectile(ptype, color, cfg, target, evo_mult := 1.0):
    cfg.dps * cfg.interval * evo_mult  # 正常
```

## 7. 特效不可见：Node2D.hide() 后 _draw() 不执行

**错误**：死亡粒子（DeathParticles）完全不可见，`_draw()` 从未被调用

**原因**：`_ready()` 调用 `hide()` 使节点不可见，但 `_on_enemy_killed()` 信号处理中只调用了 `queue_redraw()` 未调用 `show()`。Godot 在 `visible = false` 时跳过 `_draw()`。

**修复**：在激活粒子效果时调用 `show()`。

## 8. 特效一次性自杀：queue_free() 销毁持久节点

**错误**：第一批死亡粒子播放完后整个 DeathParticles 节点被 `queue_free()` 销毁，后续敌人死亡无粒子效果

**原因**：DeathParticles 设计为单例持久节点（`level_base.gd` 中创建一次），但 `_process()` 检测到所有粒子死亡后调用 `queue_free()`，等同于自杀。

**修复**：将 `queue_free()` 替换为 `_particles.clear(); set_process(false); hide()`，让节点存活以处理后续敌人死亡。

## 9. 受击闪白不可见：create_tween() 随节点销毁

**错误**：敌人被一击秒杀时受击闪白特效从未显示

**原因**：`EnemyBase.take_damage()` 使用 `create_tween()`（节点级），当 `current_hp <= 0` 触发 `_die()` → `queue_free()` 时，tween 随节点一同销毁，动画从未呈现。同时第一个 tween `tween_property(self, "modulate", Color.WHITE, 0.0)` 持续时间为 0，毫无效果。

**修复**：改用 `get_tree().create_tween()` 使 tween 独立于节点生命周期，并删除无用的 0 秒 tween。

```gdscript
# ❌ 错误
var tw := create_tween()
tw.tween_property(self, "modulate", Color.WHITE, 0.0)  # 无用
tw.tween_property(self, "modulate", Color(1,1,1,1), 0.08)
if current_hp <= 0: _die()  # queue_free → tween 销毁

# ✅ 正确
var tw := get_tree().create_tween()
tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.08)
if current_hp <= 0: _die()  # tween 仍存活
```

## 10. 缩进不一致：Unexpected "Indent" in class body

**错误**：`Unexpected "Indent" in class body`（第 N 行，第 1 列）

**原因**：Godot 4 GDScript 类体级变量通常无缩进（从第 0 列开始），但 sed 编辑时混入了 tab 或空格缩进，导致新增的变量与已有变量缩进不一致。解析器认为缩进的变量在某个不存在的块内。

**修复**：确保类体级 `var` 声明与同文件中其他变量使用相同缩进级别。Godot 类体中通常为 0 缩进。

```gdscript
# ❌ 错误——类体中混入缩进
var cached_enemies: Array = []
	var relic_manager: Node = null  # 多了 tab

# ✅ 正确——所有类体级变量一致
var cached_enemies: Array = []
var relic_manager: Node = null
```

**重要教训**：用 sed 编辑 GDScript 时，必须精确匹配目标行的缩进字符（tab vs 空格 vs 无缩进）。建议先用 `cat -A` 检查目标文件现有缩进风格再操作。

## 11. sed 插入多行代码时缩进层级错误导致 class_name 解析失败

**错误**：`Could not resolve super class inheritance from "EnemyBase"`（enemy_base.gd 本身语法正确但 class_name 未注册）

**原因**：用 `sed '/pattern/a\...'` 在 `if enemy_data:` 块内插入多行新代码时，`\t` 被解释后比目标位置多了一层缩进。新代码处于 3-tab 层级，而 `if enemy_data:` 块体为 2-tab。Godot 解析器将多出的缩进视为非法嵌套 → 函数体中断 → class_name 注册失败 → 所有子类找不到 EnemyBase。

**修复**：用 `sed 'N,Ns/^\t//'` 批量移除非预期的多余缩进。然后用 `cat -A` 验证每一行的 `^I` 数量是否符合预期。

**预防**：在 sed 中避免使用 `\t` 转义（sed 不支持），改用实际的 tab 字符或明确的行范围删除+重写。
