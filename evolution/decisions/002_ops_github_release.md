# ADR-002: 使用 ops/ 目录 + GitHub Actions 管理构建与发布

## 状态
已决定 (2026-03-27)

## 背景
项目需要统一的构建、测试、发布流程，支持 Windows 和 Android 双平台产物输出，同时兼顾本地开发便利性和 CI/CD 自动化。

## 候选方案

| 方案 | 本地构建 | CI/CD | 多平台产物 | 维护成本 |
|------|---------|-------|-----------|---------|
| ops/ + GitHub Actions | Makefile 一键命令 | tag 触发自动发布 | APK + Windows | ★★☆ |
| 纯 GitHub Actions | 无本地脚本 | 全云端构建 | APK + Windows | ★★★ |
| Fastlane | lane 命令 | 需额外配置 | APK + Windows | ★★★ |
| Codemagic | 无本地脚本 | 全托管 | APK + Windows | ★☆☆ |

## 决定
采用 ops/ 目录 + GitHub Actions 方案，原因：

1. **Makefile 统一入口**: 本地开发使用 `make build`、`make test`、`make release` 等命令，降低上手门槛
2. **Bash 脚本可复用**: `ops/scripts/` 下的 build/release/setup 脚本可在本地和 CI 中复用
3. **环境配置分离**: `ops/env/` 管理不同环境的配置，避免硬编码
4. **GitHub Actions CI/CD**:
   - `ci.yml`: PR/push 触发 lint、test、build 检查
   - `release.yml`: tag 触发自动发布，产出 APK + Windows 安装包
5. **Tag 触发发布**: 语义化版本 tag（如 `v1.0.0`）触发自动构建和 Release 创建

## 目录结构
```
ops/
├── Makefile           # 本地命令入口
├── scripts/
│   ├── build.sh       # 构建脚本
│   ├── release.sh     # 发布脚本
│   └── setup.sh       # 环境初始化
├── env/
│   ├── dev.env        # 开发环境配置
│   └── prod.env       # 生产环境配置
.github/workflows/
├── ci.yml             # CI: lint + test + build
└── release.yml        # CD: tag 触发发布
```

## 风险
- Bash 脚本在 Windows 本地需要 Git Bash 或 WSL 环境
- GitHub Actions 免费额度有限，大型构建可能超时
- 多平台构建矩阵增加 CI 复杂度

## 后续
- 考虑添加 Windows MSIX 签名流程
- 评估 Android 签名密钥的 GitHub Secrets 管理方案
- V2.0 扩展 iOS 时添加对应的 CI/CD workflow
