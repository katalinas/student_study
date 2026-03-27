# 多媒体资源清单 (Multimedia Resource Checklist)

> 最后更新: 2026-03-27

本文档列出了学生学习 App 所有模块需要的多媒体资源，按模块和优先级分类。

**优先级说明:**
- **P0 (必须有)**: 上线前必须完成，缺失会影响核心功能
- **P1 (应该有)**: 显著提升体验，第二阶段完成
- **P2 (锦上添花)**: 增强沉浸感，后续迭代完成

---

## 一、全局通用资源

### 1.1 应用图标与启动页

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 1 | `assets/images/app_icon.png` | 应用图标（iOS/Android） | PNG | 1024x1024px | P0 |
| 2 | `assets/images/app_icon_adaptive_fg.png` | Android自适应图标前景 | PNG | 432x432px | P0 |
| 3 | `assets/images/splash_screen.png` | 启动页背景图 | PNG | 1080x1920px | P0 |
| 4 | `assets/images/splash_logo.svg` | 启动页品牌标志 | SVG | 矢量 | P0 |

### 1.2 导航与模块图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 5 | `assets/icons/module_intellect.svg` | 智力模块图标 | SVG | 48x48dp | P0 |
| 6 | `assets/icons/module_logic.svg` | 逻辑模块图标 | SVG | 48x48dp | P0 |
| 7 | `assets/icons/module_tech.svg` | 科技模块图标 | SVG | 48x48dp | P0 |
| 8 | `assets/icons/module_general.svg` | 通识百科模块图标 | SVG | 48x48dp | P0 |
| 9 | `assets/icons/module_moral.svg` | 德育模块图标 | SVG | 48x48dp | P0 |
| 10 | `assets/icons/nav_home.svg` | 底部导航-首页 | SVG | 24x24dp | P0 |
| 11 | `assets/icons/nav_explore.svg` | 底部导航-探索 | SVG | 24x24dp | P0 |
| 12 | `assets/icons/nav_progress.svg` | 底部导航-进度 | SVG | 24x24dp | P0 |
| 13 | `assets/icons/nav_profile.svg` | 底部导航-我的 | SVG | 24x24dp | P0 |

### 1.3 头像与用户系统

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 14 | `assets/avatars/default_boy.png` | 默认男生头像 | PNG | 256x256px | P0 |
| 15 | `assets/avatars/default_girl.png` | 默认女生头像 | PNG | 256x256px | P0 |
| 16 | `assets/avatars/avatar_panda.png` | 可选头像-熊猫 | PNG | 256x256px | P1 |
| 17 | `assets/avatars/avatar_tiger.png` | 可选头像-老虎 | PNG | 256x256px | P1 |
| 18 | `assets/avatars/avatar_rabbit.png` | 可选头像-兔子 | PNG | 256x256px | P1 |
| 19 | `assets/avatars/avatar_dragon.png` | 可选头像-龙 | PNG | 256x256px | P1 |
| 20 | `assets/avatars/avatar_phoenix.png` | 可选头像-凤凰 | PNG | 256x256px | P1 |
| 21 | `assets/avatars/avatar_monkey.png` | 可选头像-猴子 | PNG | 256x256px | P1 |

---

## 二、智力闯关模块 (intellect)

### 2.1 学科图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 22 | `assets/icons/subject_math.svg` | 数学科目图标 | SVG | 48x48dp | P0 |
| 23 | `assets/icons/subject_chinese.svg` | 语文科目图标 | SVG | 48x48dp | P0 |
| 24 | `assets/icons/subject_english.svg` | 英语科目图标 | SVG | 48x48dp | P0 |

### 2.2 答题反馈

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 25 | `assets/audio/correct.mp3` | 答对音效 | MP3 | ≤1s | P0 |
| 26 | `assets/audio/incorrect.mp3` | 答错音效 | MP3 | ≤1s | P0 |
| 27 | `assets/audio/level_complete.mp3` | 过关音效 | MP3 | ≤2s | P0 |
| 28 | `assets/lottie/correct_check.json` | 答对动画(绿色对勾) | Lottie JSON | 150x150dp, ≤1s | P0 |
| 29 | `assets/lottie/incorrect_cross.json` | 答错动画(红色叉号) | Lottie JSON | 150x150dp, ≤1s | P0 |
| 30 | `assets/lottie/star_burst.json` | 满分星星爆炸动画 | Lottie JSON | 200x200dp, ≤2s | P1 |

---

## 三、逻辑思维模块 (logic)

### 3.1 分类图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 31 | `assets/icons/logic_pattern.svg` | 规律推理图标 | SVG | 48x48dp | P0 |
| 32 | `assets/icons/logic_deduction.svg` | 逻辑推理图标 | SVG | 48x48dp | P0 |
| 33 | `assets/icons/logic_spatial.svg` | 空间想象图标 | SVG | 48x48dp | P0 |
| 34 | `assets/icons/logic_strategy.svg` | 策略博弈图标 | SVG | 48x48dp | P0 |

### 3.2 互动素材

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 35 | `assets/images/logic/tangram_pieces.svg` | 七巧板拼图素材 | SVG | 矢量 | P1 |
| 36 | `assets/images/logic/sudoku_grid.svg` | 数独网格模板 | SVG | 矢量 | P1 |
| 37 | `assets/audio/logic_hint.mp3` | 提示音效 | MP3 | ≤1s | P1 |

---

## 四、科技探索模块 (tech)

### 4.1 子模块图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 38 | `assets/icons/tech_timeline.svg` | 科技时间线图标 | SVG | 48x48dp | P0 |
| 39 | `assets/icons/tech_virtuallab.svg` | 虚拟实验室图标 | SVG | 48x48dp | P0 |
| 40 | `assets/icons/tech_aerospace.svg` | 航天探索图标 | SVG | 48x48dp | P0 |
| 41 | `assets/icons/tech_ai.svg` | AI入门图标 | SVG | 48x48dp | P0 |

### 4.2 虚拟实验室插图

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 42 | `assets/images/tech/circuit_board.png` | 电路实验示意图 | PNG | 800x600px | P1 |
| 43 | `assets/images/tech/lever_diagram.png` | 杠杆原理示意图 | PNG | 800x600px | P1 |
| 44 | `assets/images/tech/solar_system.png` | 太阳系俯视图 | PNG | 1200x1200px | P1 |
| 45 | `assets/images/tech/rocket_parts.svg` | 火箭结构分解图 | SVG | 矢量 | P1 |
| 46 | `assets/images/tech/ai_neural_net.svg` | 神经网络简化示意图 | SVG | 矢量 | P2 |

### 4.3 科技时间线插图

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 47 | `assets/images/tech/timeline_compass.png` | 指南针插图 | PNG | 400x400px | P1 |
| 48 | `assets/images/tech/timeline_printing.png` | 活字印刷插图 | PNG | 400x400px | P1 |
| 49 | `assets/images/tech/timeline_steam.png` | 蒸汽机插图 | PNG | 400x400px | P1 |
| 50 | `assets/images/tech/timeline_computer.png` | 早期计算机插图 | PNG | 400x400px | P1 |
| 51 | `assets/images/tech/timeline_internet.png` | 互联网图标插图 | PNG | 400x400px | P1 |

---

## 五、通识百科模块 (general)

### 5.1 分类图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 52 | `assets/icons/general_geography.svg` | 地理分类图标 | SVG | 48x48dp | P0 |
| 53 | `assets/icons/general_history.svg` | 历史分类图标 | SVG | 48x48dp | P0 |
| 54 | `assets/icons/general_art.svg` | 艺术分类图标 | SVG | 48x48dp | P0 |
| 55 | `assets/icons/general_life.svg` | 生活技能分类图标 | SVG | 48x48dp | P0 |
| 56 | `assets/icons/general_science.svg` | 科学基础分类图标 | SVG | 48x48dp | P0 |
| 57 | `assets/icons/general_animals.svg` | 动植物分类图标 | SVG | 48x48dp | P0 |

### 5.2 卡片封面图片

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 58 | `assets/images/general/world_map.png` | 世界地图（七大洲四大洋标注） | PNG | 1200x800px | P1 |
| 59 | `assets/images/general/amazon_river.jpg` | 亚马逊河航拍图 | JPG | 800x600px | P2 |
| 60 | `assets/images/general/nile_river.jpg` | 尼罗河与金字塔 | JPG | 800x600px | P2 |
| 61 | `assets/images/general/himalayas.jpg` | 喜马拉雅山脉 | JPG | 800x600px | P2 |
| 62 | `assets/images/general/great_barrier_reef.jpg` | 大堡礁水下风光 | JPG | 800x600px | P2 |
| 63 | `assets/images/general/mariana_trench.png` | 马里亚纳海沟深度示意图 | PNG | 600x800px | P2 |
| 64 | `assets/images/general/pyramid.jpg` | 古埃及金字塔 | JPG | 800x600px | P1 |
| 65 | `assets/images/general/renaissance.jpg` | 文艺复兴代表画作 | JPG | 800x600px | P2 |
| 66 | `assets/images/general/moon_landing.jpg` | 阿波罗11号登月 | JPG | 800x600px | P1 |
| 67 | `assets/images/general/paper_cutting.jpg` | 中国剪纸作品 | JPG | 800x600px | P1 |
| 68 | `assets/images/general/porcelain.jpg` | 景德镇青花瓷 | JPG | 800x600px | P1 |
| 69 | `assets/images/general/dunhuang.jpg` | 敦煌飞天壁画 | JPG | 800x600px | P1 |
| 70 | `assets/images/general/erhu.jpg` | 二胡实物图 | JPG | 600x800px | P2 |
| 71 | `assets/images/general/pipa.jpg` | 琵琶实物图 | JPG | 600x800px | P2 |
| 72 | `assets/images/general/panda.jpg` | 大熊猫 | JPG | 800x600px | P0 |
| 73 | `assets/images/general/tiger.jpg` | 东北虎 | JPG | 800x600px | P1 |
| 74 | `assets/images/general/crested_ibis.jpg` | 朱鹮 | JPG | 800x600px | P1 |
| 75 | `assets/images/general/ginkgo.jpg` | 银杏树秋景 | JPG | 800x600px | P1 |
| 76 | `assets/images/general/lotus.jpg` | 荷花 | JPG | 800x600px | P1 |
| 77 | `assets/images/general/plum_blossom.jpg` | 梅花 | JPG | 800x600px | P1 |
| 78 | `assets/images/general/bamboo.jpg` | 竹林 | JPG | 800x600px | P1 |
| 79 | `assets/images/general/penguin.jpg` | 帝企鹅群 | JPG | 800x600px | P1 |
| 80 | `assets/images/general/polar_bear.jpg` | 北极熊 | JPG | 800x600px | P1 |
| 81 | `assets/images/general/bee.jpg` | 蜜蜂采蜜 | JPG | 800x600px | P2 |
| 82 | `assets/images/general/coral.jpg` | 珊瑚礁水下 | JPG | 800x600px | P2 |

---

## 六、德育融入模块 (moral)

### 6.1 分类图标

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 83 | `assets/icons/moral_quote.svg` | 每日名句图标 | SVG | 48x48dp | P0 |
| 84 | `assets/icons/moral_story.svg` | 品德故事图标 | SVG | 48x48dp | P0 |
| 85 | `assets/icons/moral_tradition.svg` | 传统文化图标 | SVG | 48x48dp | P0 |

### 6.2 故事封面图片

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 86 | `assets/images/moral/yuan_longping.jpg` | 袁隆平人物肖像/稻田 | JPG | 800x600px | P1 |
| 87 | `assets/images/moral/tu_youyou.jpg` | 屠呦呦人物肖像/青蒿 | JPG | 800x600px | P1 |
| 88 | `assets/images/moral/zhong_nanshan.jpg` | 钟南山人物肖像 | JPG | 800x600px | P1 |
| 89 | `assets/images/moral/zhang_guimei.jpg` | 张桂梅与学生 | JPG | 800x600px | P1 |
| 90 | `assets/images/moral/chen_jingrun.jpg` | 陈景润在演算 | JPG | 800x600px | P2 |
| 91 | `assets/images/moral/su_bingtian.jpg` | 苏炳添冲刺 | JPG | 800x600px | P1 |
| 92 | `assets/images/moral/zhai_zhigang.jpg` | 翟志刚太空行走 | JPG | 800x600px | P1 |
| 93 | `assets/images/moral/gu_ailing.jpg` | 谷爱凌滑雪 | JPG | 800x600px | P1 |
| 94 | `assets/images/moral/ugly_duckling.png` | 丑小鸭封面插画 | PNG | 800x600px | P1 |
| 95 | `assets/images/moral/wolf_lamb.png` | 狼和小羊封面插画 | PNG | 800x600px | P1 |
| 96 | `assets/images/moral/match_girl.png` | 卖火柴的小女孩封面插画 | PNG | 800x600px | P1 |
| 97 | `assets/images/moral/cinderella.png` | 灰姑娘封面插画 | PNG | 800x600px | P1 |
| 98 | `assets/images/moral/north_wind_sun.png` | 北风和太阳封面插画 | PNG | 800x600px | P1 |
| 99 | `assets/images/moral/emperor_clothes.png` | 皇帝的新衣封面插画 | PNG | 800x600px | P1 |
| 100 | `assets/images/moral/ant_grasshopper.png` | 蚂蚁和蚱蜢封面插画 | PNG | 800x600px | P1 |
| 101 | `assets/images/moral/fisherman_goldfish.png` | 渔夫和金鱼封面插画 | PNG | 800x600px | P1 |
| 102 | `assets/images/moral/turtle_hare.png` | 龟兔赛跑封面插画 | PNG | 800x600px | P0 |
| 103 | `assets/images/moral/boy_wolf.png` | 狼来了封面插画 | PNG | 800x600px | P0 |
| 104 | `assets/images/moral/qian_xuesen.png` | 钱学森人物肖像 | PNG | 800x600px | P1 |

### 6.3 故事朗读音频

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 105 | `assets/audio/stories/s101_turtle_hare.mp3` | 龟兔赛跑朗读 | MP3 | ~3min | P1 |
| 106 | `assets/audio/stories/s102_boy_wolf.mp3` | 狼来了朗读 | MP3 | ~3min | P1 |
| 107 | `assets/audio/stories/s201_qian_xuesen.mp3` | 钱学森故事朗读 | MP3 | ~4min | P2 |
| 108 | `assets/audio/stories/s301_yuan_longping.mp3` | 袁隆平故事朗读 | MP3 | ~5min | P2 |
| 109 | `assets/audio/stories/s302_tu_youyou.mp3` | 屠呦呦故事朗读 | MP3 | ~5min | P2 |
| 110 | `assets/audio/stories/s303_zhong_nanshan.mp3` | 钟南山故事朗读 | MP3 | ~5min | P2 |
| 111 | `assets/audio/stories/s304_zhang_guimei.mp3` | 张桂梅故事朗读 | MP3 | ~5min | P2 |
| 112 | `assets/audio/stories/s401_ugly_duckling.mp3` | 丑小鸭朗读 | MP3 | ~4min | P2 |
| 113 | `assets/audio/stories/s403_match_girl.mp3` | 卖火柴的小女孩朗读 | MP3 | ~4min | P2 |
| 114 | `assets/audio/stories/s406_emperor_clothes.mp3` | 皇帝的新衣朗读 | MP3 | ~4min | P2 |

### 6.4 经典诵读音频

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 115 | `assets/audio/classics/lunyu_excerpt.mp3` | 论语精选朗诵 | MP3 | ~3min | P2 |
| 116 | `assets/audio/classics/sanzijing_excerpt.mp3` | 三字经节选朗诵 | MP3 | ~3min | P2 |
| 117 | `assets/audio/classics/qianziwen_excerpt.mp3` | 千字文节选朗诵 | MP3 | ~3min | P2 |
| 118 | `assets/audio/classics/shenglv_excerpt.mp3` | 声律启蒙节选朗诵 | MP3 | ~2min | P2 |

---

## 七、Lottie 动画资源

### 7.1 奖励与激励

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 119 | `assets/lottie/reward_coins.json` | 获得金币动画 | Lottie JSON | 200x200dp, ≤2s | P0 |
| 120 | `assets/lottie/reward_star.json` | 获得星星动画 | Lottie JSON | 200x200dp, ≤2s | P0 |
| 121 | `assets/lottie/level_up.json` | 升级庆祝动画 | Lottie JSON | 300x300dp, ≤3s | P0 |
| 122 | `assets/lottie/celebration_confetti.json` | 彩纸庆祝动画 | Lottie JSON | 全屏, ≤3s | P1 |
| 123 | `assets/lottie/streak_fire.json` | 连续答对火焰动画 | Lottie JSON | 100x100dp, 循环 | P1 |
| 124 | `assets/lottie/badge_unlock.json` | 解锁徽章动画 | Lottie JSON | 200x200dp, ≤2s | P1 |

### 7.2 加载与过渡

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 125 | `assets/lottie/loading_spinner.json` | 通用加载动画 | Lottie JSON | 100x100dp, 循环 | P0 |
| 126 | `assets/lottie/loading_book.json` | 翻书加载动画 | Lottie JSON | 150x150dp, 循环 | P1 |
| 127 | `assets/lottie/page_turn.json` | 翻页过渡动画 | Lottie JSON | 全屏, ≤0.5s | P2 |
| 128 | `assets/lottie/empty_state.json` | 空状态动画（无内容时显示） | Lottie JSON | 200x200dp, 循环 | P1 |

### 7.3 交互反馈

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 129 | `assets/lottie/tap_ripple.json` | 点击水波纹效果 | Lottie JSON | 100x100dp, ≤0.3s | P2 |
| 130 | `assets/lottie/swipe_hint.json` | 滑动提示动画 | Lottie JSON | 200x50dp, 循环 | P2 |
| 131 | `assets/lottie/heart_like.json` | 收藏/喜欢动画 | Lottie JSON | 50x50dp, ≤0.5s | P1 |

---

## 八、背景音乐

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 132 | `assets/audio/bgm/study_calm.mp3` | 学习场景-舒缓背景音乐 | MP3 | ~3min, 循环 | P2 |
| 133 | `assets/audio/bgm/quiz_upbeat.mp3` | 答题场景-轻快背景音乐 | MP3 | ~3min, 循环 | P2 |
| 134 | `assets/audio/bgm/story_gentle.mp3` | 故事阅读-温馨背景音乐 | MP3 | ~3min, 循环 | P2 |
| 135 | `assets/audio/bgm/achievement.mp3` | 成就达成-庆祝短音乐 | MP3 | ~5s | P1 |

---

## 九、通用音效

| # | 文件路径 | 描述 | 格式 | 尺寸/时长 | 优先级 |
|---|---------|------|------|----------|--------|
| 136 | `assets/audio/sfx/button_tap.mp3` | 按钮点击音效 | MP3 | ≤0.3s | P1 |
| 137 | `assets/audio/sfx/card_flip.mp3` | 卡片翻转音效 | MP3 | ≤0.5s | P1 |
| 138 | `assets/audio/sfx/notification.mp3` | 通知提示音 | MP3 | ≤1s | P1 |
| 139 | `assets/audio/sfx/countdown_tick.mp3` | 倒计时滴答声 | MP3 | ≤0.3s | P1 |
| 140 | `assets/audio/sfx/page_turn.mp3` | 翻页音效 | MP3 | ≤0.5s | P2 |
| 141 | `assets/audio/sfx/coin_collect.mp3` | 金币收集音效 | MP3 | ≤0.5s | P1 |

---

## 统计汇总

| 类别 | P0 | P1 | P2 | 合计 |
|------|-----|-----|-----|------|
| 应用图标/启动页 | 4 | 0 | 0 | 4 |
| 导航/模块图标 | 9 | 0 | 0 | 9 |
| 头像 | 2 | 6 | 0 | 8 |
| 学科/分类图标 | 13 | 0 | 0 | 13 |
| 答题反馈(音效+动画) | 5 | 1 | 0 | 6 |
| 逻辑模块素材 | 0 | 3 | 0 | 3 |
| 科技模块插图 | 0 | 9 | 1 | 10 |
| 通识百科图片 | 1 | 18 | 6 | 25 |
| 德育故事封面 | 2 | 17 | 0 | 19 |
| 故事朗读音频 | 0 | 2 | 8 | 10 |
| 经典诵读音频 | 0 | 0 | 4 | 4 |
| Lottie动画-奖励 | 2 | 4 | 0 | 6 |
| Lottie动画-加载 | 1 | 2 | 1 | 4 |
| Lottie动画-交互 | 0 | 1 | 2 | 3 |
| 背景音乐 | 0 | 1 | 3 | 4 |
| 通用音效 | 0 | 4 | 2 | 6 |
| **合计** | **39** | **68** | **27** | **134** |

### 生产估算

| 阶段 | 内容 | 估计工作量 |
|------|------|----------|
| P0 阶段 | 39项必需资源（图标、基础动画、音效） | 设计师 2-3 周 |
| P1 阶段 | 68项提升体验资源（封面图、额外动画、音效） | 设计师 4-6 周 + 插画师 3-4 周 |
| P2 阶段 | 27项锦上添花资源（背景音乐、高级动画、额外图片） | 设计师 2-3 周 + 音频制作 1-2 周 |
| **总计** | **134项多媒体资源** | **约 12-18 周（含外包插画和音频）** |

### 资源格式规范

- **图片**: PNG（需透明背景时）或 JPG（照片类），保持 2x 分辨率以适配高清屏幕
- **图标**: SVG 矢量格式，确保任意缩放不失真
- **音频**: MP3 格式，采样率 44.1kHz，比特率 128-192kbps
- **Lottie动画**: JSON 格式，文件大小控制在 100KB 以内，帧率 30fps
- **命名规范**: 全小写，下划线分隔，模块前缀区分（如 `moral_`、`general_`）
