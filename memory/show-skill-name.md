---
name: show-skill-name
description: 调用 skill 时需要明确显示 skill 名称
metadata: 
  node_type: memory
  type: user
  originSessionId: 92087abd-a1d7-4a9c-97d6-124c5b504f60
---

调用任何 skill 时，必须在回复中明确展示正在使用的 skill 名称，让用户清楚知道当前正在调用哪个技能。

**Why:** 用户希望了解当前正在使用哪个 skill，增加操作透明度。

**How to apply:** 每次调用 Skill 工具前或同时，在回复中说明正在使用哪个 skill（例如："正在调用 **xxx** skill..."）。调用完成后展示 skill 的输出结果。
