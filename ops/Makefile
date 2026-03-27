# Student Study - Operational Commands
# Usage: make <target>

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

PROJECT_ROOT := $(shell cd .. && pwd)
OPS_DIR      := $(shell pwd)
SCRIPTS_DIR  := $(OPS_DIR)/scripts

.PHONY: help dev build-android build-windows build-all test lint clean release setup

help: ## Show this help message
	@echo "Student Study - Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

dev: ## Run in development mode with hot reload
	@bash $(SCRIPTS_DIR)/run_dev.sh

dev-android: ## Run in development mode on Android
	@bash $(SCRIPTS_DIR)/run_dev.sh --platform android

dev-windows: ## Run in development mode on Windows
	@bash $(SCRIPTS_DIR)/run_dev.sh --platform windows

build-android: ## Build Android APK (release mode)
	@bash $(SCRIPTS_DIR)/build.sh --platform android --mode release

build-windows: ## Build Windows executable (release mode)
	@bash $(SCRIPTS_DIR)/build.sh --platform windows --mode release

build-all: ## Build both Android and Windows (release mode)
	@bash $(SCRIPTS_DIR)/build.sh --platform all --mode release

build-debug: ## Build both platforms in debug mode
	@bash $(SCRIPTS_DIR)/build.sh --platform all --mode debug

test: ## Run all tests
	@cd "$(PROJECT_ROOT)" && flutter test

lint: ## Run dart analyze
	@cd "$(PROJECT_ROOT)" && dart analyze

clean: ## Clean build artifacts and dist directory
	@echo "Cleaning build artifacts..."
	@cd "$(PROJECT_ROOT)" && flutter clean
	@rm -rf "$(OPS_DIR)/dist/"*
	@touch "$(OPS_DIR)/dist/.gitkeep"
	@echo "Clean complete."

release: ## Create a tagged release with artifacts
	@bash $(SCRIPTS_DIR)/release.sh

setup: ## Check prerequisites and install dependencies
	@bash $(SCRIPTS_DIR)/setup_env.sh
