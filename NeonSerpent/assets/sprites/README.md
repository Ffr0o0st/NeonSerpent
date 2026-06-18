# 蛇卫核心 — 美术资源完整规范

## 风格总纲

**主题**：赛博机械 × 霓虹能量。所有实体为机械构造体，暗金属装甲+霓虹辉光。

**配色系统**：玩家方冷色青蓝系 ↔ 敌方暖色红橙紫系，强烈敌我识别。

**复杂度基准**：每实体 5-10 层视觉元素，全实体统一标准。

---

## 技术约束（每个 prompt 必须满足）

以下约束已嵌入所有 prompt，是资源能否在游戏中正确使用的硬性条件：

| 约束 | 要求 | 为什么 |
|------|------|--------|
| **视角** | 正俯视（top-down），如同从正上方 90° 垂直向下看 | 游戏是 30×30 网格俯视视角，侧视/透视资源会严重出戏 |
| **朝向** | 蛇头朝右、炮管朝右、敌人朝右或居中对称 | Godot 用 `rotation` 旋转朝向，所有资源默认指向 0°（右侧） |
| **边缘** | 清晰硬边，**禁止抗锯齿** | 导入设置 `Filter: Off` (Nearest)，抗锯齿资源缩放后会模糊 |
| **背景** | 纯黑 `#0A0A14`，**禁止渐变黑** | 渐变黑无法与游戏背景（同色 `#0A0A14`）干净融合，去背后会留下光晕痕迹 |
| **发光** | 亮区（辉光核心/能量线）与暗区（金属装甲）**对比鲜明** | Godot WorldEnvironment Glow 后处理只对高亮区生效。亮区→bloom 辉光，暗区→保持稳定 |
| **透明度** | 实体边缘与背景之间**硬切割**，无半透明过渡像素 | 半透明边缘在游戏中会呈现灰色光晕（黑色背景透过 alpha 混合的结果） |
| **尺寸** | **精确**像素尺寸，不做"大约" | Nearest 过滤下任何缩放都会导致锯齿或模糊 |
| **风格统一** | 所有实体同为"暗金属装甲+霓虹发光脉络"风格 | 混合不同渲染风格（如写实3D+平面矢量）会破坏整体感 |
| **色彩** | 亮区使用策划案指定 Hex 色值，暗金属部分使用深灰 `#1a1a2e` ~ `#2a2a3e` | 确保游戏中颜色与设计一致，Glow 后处理依赖准确色值 |
| **格式** | 透明 PNG，sRGB 色彩空间 | Godot 标准导入格式 |

### 俯视视角说明

游戏摄像机从正上方俯视 30×30 网格。每个实体是放在网格上的"棋子"。正确和错误的示例如下：

- **蛇头**：俯视看蛇的头顶——看到的是蛇首的顶部装甲板和中心眼，**不是**蛇的侧面。正确参考：从正上方看一条机械蛇的头顶。
- **蛇身**：俯视看一个六边形环——看到的是环的平面，**不是**立体环的侧面。
- **炮台**：俯视看蛇身环上的武器模块——炮管从环向外（右）水平伸出。正确参考：从正上方看炮管。
- **敌人**：俯视看机械单位——看到的是机体的顶部装甲，**不是**侧面。对于多足机体，可见腿部从机体边缘向外伸展的俯视投影。
- **核心**：俯视看晶体顶部——看到的是八边形的顶面。

---

## 统一 AI Prompt 模板（完整版，含所有约束）

```
2D game sprite, top-down bird-eye view, [subject description],
neon glow on bright emissive areas only, dark metallic structural body with deep grey armor (#1a1a2e),
sharp defined pixel edges no anti-aliasing, clean silhouette, pure black background #0A0A14,
cyberpunk mechanical design, Tron-inspired energy veins, emission bloom,
consistent style across all sprites, flat orthographic top-down perspective, no text, centered
```

---

## 一、玩家实体（青蓝冷色系）

### 蛇头 (snake_head.png) — 48×48 px
```
2D game sprite, top-down bird-eye view of a biomechanical serpent head seen from directly above,
sleek organic head shape with layered geometric armor plates on the top surface,
bright cyan neon energy vein (#00FFFF) running along center spine from nose tip to neck base,
3-4 branching circuit lines on each side of the central vein,
hexagonal eye core in pure white with cyan halo at center-top of head,
dark metallic side armor plates (#1a1a2e) with thin cyan (#00FFFF) edge highlights,
4-6 tiny cyan light particles hovering above the head,
head pointing to the right, sharp pixel edges no anti-aliasing,
pure black background #0A0A14, emission bloom, no text, centered
```

### 蛇身 (snake_body.png) — 32×32 px
```
2D game sprite, top-down bird-eye view of a hexagonal ring segment seen from directly above,
outer hexagon in thick neon blue (#0088FF) solid bright line,
inner hexagon in thinner neon blue (#0088FF) at lower intensity,
glowing neon blue circle dot at exact center,
dark metallic thin frame structure (#1a1a2e) connecting the hexagon corners,
sharp pixel edges no anti-aliasing, pure black background #0A0A14,
cyberpunk mechanical precision, emission bloom, no text, centered
```

### 蛇身·瘫痪 (snake_body_disrupted.png) — 32×32 px
```
2D game sprite, top-down bird-eye view of a corrupted hexagonal ring segment seen from above,
broken irregular hexagon ring in flickering neon red (#FF2222) with jagged fracture gaps,
central circle glowing unstable red with tiny glitch spark particles,
dark metallic frame (#1a1a2e) partially shattered with cracks,
sharp pixel edges no anti-aliasing, pure black background #0A0A14,
cyberpunk damage malfunction effect, emission bloom, no text, centered
```

### 核心 (core.png) — 64×64 px
```
2D game sprite, top-down bird-eye view of an octagonal crystal energy core seen from directly above,
solid faceted gold crystal center (#FFD700) with bright platinum white (#FFFFFF) edge highlights on each facet,
3 thin rotating satellite rings at different tilt angles around the crystal drawn as flat ellipses in gold,
8 small bright energy particles evenly spaced along the outermost ring,
internal geometric crystal facets visible through translucent golden top surface,
dark metallic mounting base (#1a1a2e) as thin outer frame,
sharp pixel edges no anti-aliasing, pure black background #0A0A14,
cyberpunk power generator, emission bloom, no text, centered
```

### 核心·护盾 (core_shield.png) — 80×80 px
```
2D game sprite, top-down circular semi-transparent shield bubble seen from above,
soft blue-white glow (#AADDFF) with faint hexagonal grid pattern on the shield surface,
thin bright white ring at the shield perimeter edge,
subtle energy flow lines across the surface in light blue,
sharp pixel edges on the ring, soft glow on the surface,
pure black background #0A0A14, cyberpunk defensive barrier, emission bloom, no text, centered
```

### 食物 (food.png) — 16×16 px
```
2D game sprite, top-down view of a small bright neon green glowing diamond crystal,
rotated 45 degrees, bright green core (#00FF66) with darker green (#00CC44) geometric frame edge,
double glow halo (inner bright, outer subtle at half intensity),
sharp pixel edges no anti-aliasing, pure black background #0A0A14,
cyberpunk energy pickup, emission bloom, no text, centered
```

---

## 二、炮台 — 六边形环 + 武器模块（32×32 px 统一）

所有炮台共享基础结构：俯视蛇身六边形环+中心蓝圆点（与普通蛇身完全一致），武器从环的右侧水平伸出。

### 机枪炮台 (turret_machinegun.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, two short parallel gun barrels extending horizontally right from the right edge of the hexagon, barrels thick at base tapering to front with heat vent groove lines, bright yellow glow (#FFFF44) at barrel tips, thin blue energy line connecting center dot to barrel base, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

### 迫击炮炮台 (turret_mortar.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, wide short mortar barrel extending horizontally right and very slightly upward from the hexagon, thick reinforced rectangular breech block at barrel base, bright orange glow (#FFAA00) at muzzle opening, thin blue energy line from center dot to breech, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

### 激光炮台 (turret_laser.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, slim long cylindrical focusing lens barrel extending horizontally right from the hexagon, 3 evenly spaced ring-shaped focusing nodes along the lens barrel, bright red glow (#FF3333) at lens tip, thin blue energy line from center dot to barrel base, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

### 冰冻炮台 (turret_ice.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, irregular hexagonal ice crystal shaped emitter extending horizontally right from the hexagon, frost texture vein lines on crystal facets, ice blue glow (#88DDFF) with tiny white frost particle specks around crystal tip, thin blue energy line from center dot to crystal base, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

### 火焰炮台 (turret_flame.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, wide flared cone nozzle barrel extending horizontally right from the hexagon, irregular heat sink fin ridges along nozzle sides, small static flame teardrop shape at nozzle tip in orange-red (#FF6600), thin blue energy line from center dot to nozzle base, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

### 闪电炮台 (turret_lightning.png)
```
2D game sprite, top-down bird-eye view, hexagonal ring with neon blue (#0088FF) glow and blue center dot matching snake body segment, forked twin-prong electrode emitter extending horizontally right from the hexagon, tiny static electric arcs between the prong tips drawn as 2-3 small zigzag lines in pure white (#FFFFFF), electric blue corona halo around the prongs, thin blue energy line from center dot to electrode base, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, emission bloom, no text, centered
```

---

## 三、敌军 — 赛博机械军团（暖色红橙紫系，全部俯视）

### 爬行者 — 侦察蛛机 (enemy_crawler.png) — 32×32 px
```
2D game sprite, top-down bird-eye view of a small four-legged mechanical spider drone seen from directly above, central hexagonal body chassis with dark orange (#FF6600) glowing core at center, four thin jointed mechanical legs spreading outward symmetrically from body with 3 small articulated orange glowing nodes per leg, single bright orange sensor eye dome on top center of body, light armor panel lines on body surface, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk scouting unit, emission bloom, no text, centered
```

### 疾行者 — 突击悬浮机 (enemy_runner.png) — 32×32 px
```
2D game sprite, top-down bird-eye view of a sleek arrowhead-shaped hovering drone seen from above, sharp nose pointing right with two swept-back wing blades on sides, bright yellow (#FFDD00) glow from twin circular engine thruster nozzles at the rear, single energy rail line along center spine from nose to tail getting progressively brighter, soft hover glow pad as a faint circle beneath the body center, streamlined metallic dark grey body (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk speed interceptor, emission bloom, no text, centered
```

### 重装兵 — 重甲步行机 (enemy_heavy.png) — 48×48 px
```
2D game sprite, top-down bird-eye view of a heavy armored quadruped walker mech seen from directly above, thick square dark red (#CC0000) armor plates with glowing white-hot energy seams at the plate joint lines, four circular shield generator nodes at the four corners drawn as subtle dark rings with faint white dot center, short stubby central barrel on the front-right face, four thick mechanical legs extending outward with visible hydraulic piston joints, imposing tank silhouette, dark metallic frame (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk heavy assault unit, emission bloom, no text, centered
```

### 干扰者 — 信号干扰机 (enemy_disruptor.png) — 36×36 px
```
2D game sprite, top-down bird-eye view of a hovering satellite-shaped electronic warfare unit seen from above, central octagonal body chassis with neon purple (#CC00FF) glow from the core, four thin antenna rods extending diagonally outward from the four corner faces with small spherical glowing purple emitter tips, two thin flat ring ellipses at different tilt angles around the body representing rotating signal rings, subtle static pulse wave arcs radiating from antenna tips as thin concentric arc lines, dark metallic body (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk jammer satellite, emission bloom, no text, centered
```

### 自爆虫 — 爆裂蛛机 (enemy_bomber.png) — 28×28 px
```
2D game sprite, top-down bird-eye view of a compact four-legged spider-mine robot seen from above, spherical explosive core body with glowing orange-red (#FF4400) unstable energy visible through cracked dark armor shell surface, bright white-hot (#FFFFFF) fracture lines branching across the core like cracked glass, four short mechanical legs tucked underneath barely visible at edges, thin outer danger glow ring in orange-red pulsing at half alpha around the body, tense coiled silhouette, dark metallic armor (#1a1a2e), sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk explosive mine unit, emission bloom, no text, centered
```

### 增幅巨兽 — 移动要塞 (enemy_behemoth.png) — 64×64 px
```
2D game sprite, top-down bird-eye view of a massive six-legged heavy assault mech boss seen from directly above, multi-layered square armor construction with outer blood-red (#FF0000) heavy armor plates, middle dark grey (#2a2a3e) structural frame visible at the plate edges, inner glowing crimson (#FF0000) energy reactor core at exact center with white-hot center dot, multiple small decorative weapon hardpoints as tiny dark circles across the hull surface, 3 thin concentric rotating defense rings as flat ellipses around the body with 8 bright particles evenly spaced on the outermost ring, six thick mechanical legs extending outward symmetrically with heavy hydraulic joint details, imposing fortress silhouette, dark metallic frame, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk boss unit, emission bloom, no text, centered
```

### 镜像蛇 — 腐化蛇首 (enemy_mirror.png) — 48×48 px
```
2D game sprite, top-down bird-eye view of a corrupted mirror version of the biomechanical serpent head seen from above, same sleek head shape and armor plate structure as the player snake head but mirrored orientation pointing left, dark semi-transparent purple (#9900CC) color at approximately 60 percent opacity creating ghostly see-through effect, horizontal glitch fracture lines cutting across the head with small pixelated block displacement offsets, energy veins changed from cyan to flickering dark purple with occasional dark spots, central eye core glowing unstable purple with dark flicker artifacts, ghostly ethereal corrupted appearance, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk corrupted clone, emission bloom, no text, centered
```

---

## 四、UI 元素

统一：暗蓝半透明底 + 霓虹青边框。2D 平面 UI，无透视。

### 面板背景 (panel_bg.png) — 480×64 px
```
2D flat game UI element, horizontal rectangular panel, dark blue semi-transparent fill with neon cyan (#00FFFF) thin 1-pixel border with subtle inner cyan glow, faint diagonal scanline pattern across the surface, small diamond-shaped status indicator dot in cyan at top-left corner, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk HUD panel, no text, centered
```

### 面板背景·高版 (panel_bg_tall.png) — 480×320 px
```
2D flat game UI element, tall vertical rectangular panel, dark blue semi-transparent fill with neon cyan (#00FFFF) thin 1-pixel border with subtle inner cyan glow, faint diagonal scanline pattern across the surface, small diamond-shaped status indicator dot in cyan at top-left corner, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk HUD panel, no text, centered
```

### 按钮·常态 (btn_normal.png) — 240×48 px
```
2D flat game UI button, horizontal rectangular button, dark blue fill with neon cyan (#00FFFF) thin 1-pixel border, subtle inner shadow for depth, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk HUD button, no text, centered
```

### 按钮·悬停 (btn_hover.png) — 240×48 px
```
2D flat game UI button, horizontal rectangular button, dark blue fill slightly lighter than normal state, bright neon cyan (#00FFFF) thicker 2-pixel glowing border, outer cyan glow halo beyond the border, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk HUD button highlighted, no text, centered
```

### 按钮·按下 (btn_pressed.png) — 240×48 px
```
2D flat game UI button, horizontal rectangular button, bright cyan (#00FFFF) filled with darker blue thin border, inverted color from normal state, inset shadow for pressed depth, sharp pixel edges no anti-aliasing, pure black background #0A0A14, cyberpunk HUD button active, no text, centered
```

### 标题 Logo (title_logo.png) — 640×160 px
```
2D flat game title logo, bold futuristic cyberpunk typography text "NEON SERPENT", neon cyan (#00FFFF) main lettering with neon blue (#0088FF) outline glow halo, Tron-inspired letter shapes with subtle circuit line decorations connecting between letters, sharp pixel edges no anti-aliasing, pure black background #0A0A14, centered composition, emission bloom, no additional text
```

---

## 五、图标（24×24 px 统一）

| 文件 | Prompt |
|------|--------|
| `icon_health.png` | `2D flat game UI icon, small neon golden (#FFD700) heart shape, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |
| `icon_shield.png` | `2D flat game UI icon, small neon blue (#AADDFF) shield shape, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |
| `icon_kill.png` | `2D flat game UI icon, small neon yellow (#FFDD00) crosshair reticle shape, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |
| `icon_food.png` | `2D flat game UI icon, small neon green (#00FF66) diamond crystal shape, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |
| `icon_wave.png` | `2D flat game UI icon, small neon white (#E0E0FF) three horizontal wave lines stacked, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |
| `icon_turret.png` | `2D flat game UI icon, small neon yellow (#FFFF44) mini hexagonal turret shape, clean geometric, tiny glow halo, sharp pixel edges, pure black background, top-down icon, 24 by 24 pixels` |

---

## 六、粒子 / 特效

| 文件 | 尺寸 | Prompt |
|------|------|--------|
| `particle_glow.png` | 4×4 px | `tiny soft white glow dot with subtle cyan halo, pure black background, sharp pixel edges, 2D game particle, 4 by 4 pixels` |
| `particle_spark.png` | 4×4 px | `tiny bright warm orange spark particle with small glow, pure black background, sharp pixel edges, 2D game particle, 4 by 4 pixels` |
| `particle_ring.png` | 64×64 px | `thin neon glowing circle ring, semi-transparent center, cyan-white emission bloom at ring edge, pure black background, sharp pixel edges on ring, 2D game effect, 64 by 64 pixels` |
| `particle_beam.png` | 4×128 px | `thin vertical neon cyan glowing beam line, soft feathered edges fading to transparent, bright center line, pure black background, 2D game effect, 4 by 128 pixels` |

---

## 七、生成流程

1. 复制单个 prompt 到生成平台（nano banana 2 / DALL-E 3 / SD / MJ）
2. 每个实体生成 3-5 个变体，挑选最符合约束的
3. 去背处理（remove.bg / Photoshop / GIMP）→ 透明 PNG
4. **精确**缩放到指定像素尺寸
5. 边缘清理：确保实体边缘是硬切割，无半透明过渡像素
6. 按目录结构保存

## 八、Godot 导入设置

- **Filter**：Off（Nearest）
- **Mipmaps**：Off
- **Compress**：Lossless
- 发光效果由 WorldEnvironment Glow（Intensity=0.8, Blend=Additive）统一实现

## 九、验收检查清单

生成每张图后，逐项检查：

- [ ] 是正俯视视角（不是侧视、透视或 3/4 角）？
- [ ] 朝向正确（蛇头/炮管朝右，敌人朝右或居中对称）？
- [ ] 尺寸精确匹配（不是"差不多"）？
- [ ] 边缘是硬像素边（无模糊抗锯齿）？
- [ ] 背景是纯黑 #0A0A14（无渐变）？
- [ ] 亮区和暗区对比鲜明（Glow 后处理需要）？
- [ ] 实体边缘与背景间无半透明过渡像素？
- [ ] 与同系统其他资源风格一致？

---

## 十、资源清单

| 类别 | 数量 | 文件 |
|------|------|------|
| 玩家实体 | 5 | snake_head(48), snake_body(32), snake_body_disrupted(32), core(64), core_shield(80) |
| 食物 | 1 | food(16) |
| 炮台 | 6 | machinegun/mortar/laser/ice/flame/lightning (均32) |
| 敌军 | 7 | crawler(32), runner(32), heavy(48), disruptor(36), bomber(28), behemoth(64), mirror(48) |
| UI 面板 | 2 | panel_bg(480×64), panel_bg_tall(480×320) |
| UI 按钮 | 3 | btn_normal/hover/pressed (均240×48) |
| UI 图标 | 6 | health/shield/kill/food/wave/turret (均24) |
| UI 标题 | 1 | title_logo(640×160) |
| 粒子特效 | 4 | glow(4), spark(4), ring(64), beam(4×128) |
| **合计** | **35** | |
