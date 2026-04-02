# ============================================================================
# 少年研学 (Student Study) — 本地开发 Makefile
# ============================================================================
# 用法: make <target>
#   make setup      — 首次环境初始化（依赖安装 + 代码生成）
#   make run        — 默认运行 Web 版 (Chrome)
#   make run-win    — 运行 Windows 桌面版
#   make run-web    — 运行 Web 版
#   make run-android— 运行 Android 版
#   make build      — 构建全部平台 release 版
#   make check      — 静态分析 + 测试
# ============================================================================

.PHONY: help setup deps codegen run run-web run-win run-android \
        build build-web build-win build-apk \
        check analyze test clean doctor

# 默认目标
help: ## 显示帮助
	@echo "============================================"
	@echo "  少年研学 本地开发命令"
	@echo "============================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ── 环境 ───────────────────────────────────────────────────────
setup: deps codegen ## 首次环境初始化（安装依赖 + 代码生成）
	@echo "✅ 环境初始化完成"

deps: ## 安装 Flutter 依赖
	flutter pub get

codegen: ## 运行代码生成（build_runner）
	dart run build_runner build --delete-conflicting-outputs

codegen-watch: ## 代码生成监听模式
	dart run build_runner watch --delete-conflicting-outputs

doctor: ## 检查 Flutter 环境
	flutter doctor -v

# ── 运行 ───────────────────────────────────────────────────────
run: run-web ## 默认运行（Web Chrome）

run-web: ## 运行 Web 版 (Chrome)
	flutter run -d chrome

run-win: ## 运行 Windows 桌面版
	flutter run -d windows

run-android: ## 运行 Android 版
	flutter run -d android

# ── 构建 ───────────────────────────────────────────────────────
build: build-web build-apk ## 构建全部平台 release

build-web: ## 构建 Web release
	flutter build web --release
	@echo "✅ Web 构建完成 → build/web/"

build-win: ## 构建 Windows release
	flutter build windows --release
	@echo "✅ Windows 构建完成 → build/windows/x64/runner/Release/"

build-apk: ## 构建 Android APK release
	flutter build apk --release
	@echo "✅ APK 构建完成 → build/app/outputs/flutter-apk/app-release.apk"

# ── 质量 ───────────────────────────────────────────────────────
check: analyze test ## 静态分析 + 测试

analyze: ## 运行 Dart 静态分析
	flutter analyze

test: ## 运行单元测试
	flutter test

# ── 维护 ───────────────────────────────────────────────────────
clean: ## 清理构建缓存
	flutter clean
	@echo "✅ 已清理。运行 make setup 重新初始化。"

reinstall: clean deps ## 清理并重新安装依赖
	@echo "✅ 重新安装完成"
