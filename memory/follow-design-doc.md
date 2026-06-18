---
name: follow-design-doc
description: 始终遵循策划案编写代码，不随意偏离设计文档中的数值和规则
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 92087abd-a1d7-4a9c-97d6-124c5b504f60
---

编写任何游戏逻辑代码时，必须严格参照策划案 `2D游戏Demo策划案 — 蛇卫核心.md` 中的数值、规则和设计意图。不得自行创造或修改策划案中已明确定义的参数。

**Why:** 用户发现之前有偏离策划案的情况，需要确保代码实现与设计文档一致。

**How to apply:** 编写代码前先查阅策划案对应章节，确认数值（HP、速度、伤害、数量等）和规则后再实现。策划案未覆盖的细节才自行补充。
