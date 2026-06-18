---
name: record-errors
description: 用户报错时自动记录错误原因和修复方法到记忆系统
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 92087abd-a1d7-4a9c-97d6-124c5b504f60
---

当用户在对话中提供报错内容（Parser Error、运行时错误等）时，必须在修复完成后调用 `/remember` 命令将该错误的**原因**和**修复方法**记录下来。格式为：

```
/remember >godot workspace [错误类型]： [原因] → [修复方法]
```

**场景示例**：
- 用户贴出 `Parser Error: Could not find base class "TurretBase"` → 记录：Godot class_name 加载顺序问题，新脚本 extends 自定义类时可能因编译顺序找不到基类，改为 extends Node2D 自包含实现
- 用户贴出 `Constant "_projectile_scene" has the same name` → 记录：重复声明常量，编辑时追加了已有声明，修复前先 grep 检查

**Why:** 用户希望在项目开发过程中积累常见错误的教训，避免在同一类问题上反复浪费时间。

**How to apply:** 每次修复完用户报告的编译/运行时错误后，立即调用 `/remember` 记录。使用 `workspace` 作用域（项目级），`godot` 领域。
