# 蛇卫核心 — 美术资源获取完整指南

## 一、总体策略

游戏采用 **赛博霓虹（Cyber Neon）** 视觉风格：暗黑底色 + 发光实体 + 粒子弹幕。这种风格对 AI 图像生成非常友好——发光和霓虹是 AI 最擅长的领域。

### 三管齐下方案

| 方案 | 适用实体 | 优势 |
|------|---------|------|
| AI 生成 | 蛇头、核心、所有 7 种敌人 | 质量高、风格统一、适合求职展示 |
| Godot 程序化 | 蛇身段、食物、弹道粒子、网格线 | 无需外部素材、文件极小、灵活调色 |
| Godot Theme | HUD 面板、按钮、进度条 | 系统原生、主题化统一调整 |

---

## 二、AI 生成操作步骤

### 2.1 工具选择

| 工具 | 费用 | 质量 | 推荐场景 |
|------|------|------|---------|
| **Midjourney** | $10-30/月 | ★★★★★ | 最佳质量，适合最终版素材 |
| **DALL-E 3** | ChatGPT Plus 内置 | ★★★★☆ | 快速原型，便捷 |
| **Stable Diffusion** | 免费 | ★★★☆☆ | 零成本，需本地 GPU |

### 2.2 通用 Prompt 模板

复制以下模板，将 `[实体描述]` 替换为具体描述：

```
2D game asset, [实体描述], neon glow style, dark black background, cyberpunk aesthetic, Tron-inspired, clean geometric shapes, glowing edges, emission bloom, vector art, game sprite --ar 1:1 --style raw
```

### 2.3 逐实体 Prompt（复制即用）

| 实体 | 完整 Prompt |
|------|-----------|
| 蛇头 | `2D game asset, glowing cyan arrowhead pointing right, neon outline, dark black background, cyberpunk aesthetic, Tron-inspired, clean geometric triangle, glowing edges, emission bloom, vector art, game sprite --ar 1:1 --style raw` |
| 核心 | `2D game asset, golden glowing crystal core with pulsing halo rings, neon style energy sphere, Tron-inspired, dark black background, clean geometric circle, emission bloom, vector art, game sprite --ar 1:1 --style raw` |
| 爬行者 | `2D game asset, glowing dark orange diamond shape creature, neon outline, faceless, clean geometric edges, dark black background, cyberpunk aesthetic, Tron-inspired, 2D game enemy sprite --ar 1:1 --style raw` |
| 疾行者 | `2D game asset, glowing neon yellow triangle shape with speed motion trail, neon outline, fast creature, dark black background, Tron-inspired, 2D game enemy sprite --ar 1:1 --style raw` |
| 重装兵 | `2D game asset, large dark red square enemy with glowing white border edges, heavy armored geometric shape, neon style, dark black background, Tron-inspired, 2D game enemy sprite --ar 1:1 --style raw` |
| 干扰者 | `2D game asset, glowing neon purple diamond with pulsing aura rings, geometric creature, faceless, dark black background, cyberpunk aesthetic, 2D game enemy sprite --ar 1:1 --style raw` |
| 自爆虫 | `2D game asset, glowing orange-red flickering unstable orb, geometric sphere, neon style, dark black background, Tron-inspired, 2D game enemy sprite --ar 1:1 --style raw` |
| 增幅巨兽 | `2D game asset, massive blood red square boss entity with expanding aura shockwave rings, geometric, neon glow, dark black background, Tron-inspired, 2D game boss sprite --ar 1:1 --style raw` |
| 镜像蛇 | `2D game asset, dark purple semi-transparent ghostly snake arrowhead, ghostly glow, geometric, neon style, dark black background, 2D game enemy sprite --ar 1:1 --style raw` |

### 2.4 后处理步骤

1. **去背**（移除黑色背景，保留透明 PNG）
   - 在线工具: https://remove.bg（免费额度）
   - Photoshop: 魔棒工具 → 选择黑色背景 → Delete
   - GIMP: Fuzzy Select → Delete
   
2. **尺寸调整**
   - 蛇头: 48×48px
   - 核心 / 增幅巨兽: 64×64px
   - 重装兵 / 镜像蛇: 48×48px
   - 干扰者: 36×36px
   - 爬行者 / 疾行者: 32×32px
   - 自爆虫: 28×28px

3. **保存**
   - 格式: PNG（RGBA，透明背景）
   - 目录: `assets/sprites/`
   - 文件名: `snake_head.png`, `core.png`, `enemy_crawler.png` 等（见 sprites/README.md）

---

## 三、Godot 程序化绘制方案

以下实体**不需要**外部图片，直接在 Godot 中用代码绘制：

### 3.1 蛇身段（发光圆点）

```gdscript
# 在 _draw() 中绘制
func _draw() -> void:
    var color := Color("#0088FF")
    draw_circle(Vector2(16, 16), 12.0, color)  # 半径 12px
    # 外层光晕
    draw_circle(Vector2(16, 16), 16.0, Color(color, 0.3))
```

### 3.2 食物（发光小方块）

```gdscript
func _draw() -> void:
    var color := Color("#00FF66")
    draw_rect(Rect2(4, 4, 8, 8), color)
    draw_rect(Rect2(2, 2, 12, 12), Color(color, 0.3), false, 1.0)
```

### 3.3 弹道粒子

每种弹道颜色只需一个 8×8 的发光小圆：
```gdscript
draw_circle(Vector2(4, 4), 3.0, bullet_color)
```

### 3.4 网格线

已在 `grid_overlay.gd` 的 `_draw()` 中实现：暗霓虹蓝细线。

### 3.5 HUD 面板

使用 Godot UI 系统 + Theme：
- `PanelContainer` + `StyleBoxFlat` 背景色 rgba(10,10,40,0.8)
- 边框用 `StyleBoxFlat` draw 模式
- 文字用 `Label` + 等宽字体 + 发光 shader

---

## 四、Godot Glow（发光）配置

所有发光效果由 `WorldEnvironment` 节点的 Glow 后处理统一实现，不需要在素材上做额外处理。

在任一关卡场景中：
1. 选择 `WorldEnvironment` 节点
2. `Environment` → `Glow` → 启用
3. 参数：
   - Intensity: **0.8**
   - Blend Mode: **Add**
   - HDR Threshold: **0.9**
   - HDR Bleed Scale: **2.0**

精灵材质设置 `Emission` 属性为 `true` 即可自动被 Glow 捕获并产生辉光。

---

## 五、音频资源（后续）

策划案已标注方向：
- 音乐: Synthwave / 暗黑合成器（可从 Pixabay、Freesound 获取免费素材）
- 音效: 开源音效库（OpenGameArt、Freesound）
- 当前为 Demo 阶段，音频系统已留桩（AudioManager），可先静音运行

---

## 六、快速启动建议

**最小可行素材集**（仅需 AI 生成 3 张图即可玩起来）：
1. 蛇头 → 48×48px 青色三角箭头
2. 核心 → 64×64px 金色发光球
3. 爬行者（第 1 关唯一敌人）→ 32×32px 暗橙菱形

其余实体先用 Godot 程序化绘制占位，后续逐步替换为 AI 生成素材。
