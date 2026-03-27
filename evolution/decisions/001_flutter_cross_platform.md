# ADR-001: 选择 Flutter 作为跨平台框架

## 状态
已决定 (2026-03-27)

## 背景
需要一套代码运行在 Windows 和 Android 上，目标用户为6-15岁学生，对UI表现力和交互动画要求较高。

## 候选方案

| 方案 | Windows | Android | UI表现力 | 生态 | 性能 |
|------|---------|---------|---------|------|------|
| Flutter | ✅ | ✅ | ★★★ | ★★☆ | ★★★ |
| React Native | ⚠️(Electron) | ✅ | ★★☆ | ★★★ | ★★☆ |
| Kotlin Multiplatform | ⚠️(Compose) | ✅ | ★★☆ | ★★☆ | ★★★ |
| Electron + Web | ✅ | ⚠️(WebView) | ★★☆ | ★★★ | ★☆☆ |

## 决定
选择 Flutter，原因：
1. 一套代码同时支持 Windows 桌面端和 Android 移动端
2. UI 渲染引擎（Skia/Impeller）表现力强，适合儿童教育类丰富界面
3. 自绘 UI 保证双平台视觉一致性
4. 丰富的动画 API，适合游戏化学习交互
5. 后期扩展 iOS、Web 成本低

## 风险
- Windows 桌面端生态相比移动端不够成熟
- 部分原生功能可能需要 platform channel
- 包体积较大（约 15-20MB 基础）

## 后续
- V2.0 扩展 iOS 和 Web 时评估 Flutter Web 性能
- 关注 Impeller 渲染引擎在 Windows 上的稳定性
