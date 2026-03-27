#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# setup_env.sh - Verify prerequisites and set up the
# development environment for the Student Study app.
#
# Checks: Flutter SDK, Dart, Android SDK, Git
# Runs:   flutter doctor, flutter pub get
#
# Usage:
#   ./setup_env.sh
# -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS_DIR}/.." && pwd)"

ERRORS=0

echo "========================================="
echo "  Environment Setup - Student Study"
echo "========================================="
echo ""

# -------------------------------------------------------
# Helper: check if a command exists
# -------------------------------------------------------
check_command() {
    local cmd="$1"
    local label="${2:-$1}"
    local install_hint="${3:-}"

    if command -v "${cmd}" &>/dev/null; then
        local version
        version="$("${cmd}" --version 2>/dev/null | head -1 || echo "installed")"
        echo "  [OK]  ${label}: ${version}"
    else
        echo "  [FAIL] ${label}: not found"
        if [[ -n "${install_hint}" ]]; then
            echo "         Install: ${install_hint}"
        fi
        ERRORS=$((ERRORS + 1))
    fi
}

# -------------------------------------------------------
# 1. Check required tools
# -------------------------------------------------------
echo "Checking prerequisites..."
echo ""

check_command "flutter" "Flutter SDK" "https://docs.flutter.dev/get-started/install"
check_command "dart" "Dart SDK" "Included with Flutter SDK"
check_command "git" "Git" "https://git-scm.com/downloads"

echo ""

# -------------------------------------------------------
# 2. Check Android SDK (for Android builds)
# -------------------------------------------------------
echo "Checking Android SDK..."

if [[ -n "${ANDROID_HOME:-}" ]] || [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
    SDK_PATH="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
    echo "  [OK]  Android SDK: ${SDK_PATH}"

    # Check for required build tools
    if [[ -d "${SDK_PATH}/build-tools" ]]; then
        BUILD_TOOLS_VERSION="$(ls "${SDK_PATH}/build-tools" 2>/dev/null | sort -V | tail -1 || true)"
        if [[ -n "${BUILD_TOOLS_VERSION}" ]]; then
            echo "  [OK]  Build Tools: ${BUILD_TOOLS_VERSION}"
        else
            echo "  [WARN] Build Tools: none found in ${SDK_PATH}/build-tools"
        fi
    fi

    # Check for platform tools
    if [[ -d "${SDK_PATH}/platform-tools" ]]; then
        echo "  [OK]  Platform Tools: present"
    else
        echo "  [WARN] Platform Tools: not found"
    fi
else
    echo "  [WARN] ANDROID_HOME / ANDROID_SDK_ROOT not set"
    echo "         Android builds may fail. Set one of these environment variables."
    echo "         Common paths:"
    echo "           Windows: C:\\Users\\<user>\\AppData\\Local\\Android\\Sdk"
    echo "           macOS:   ~/Library/Android/sdk"
    echo "           Linux:   ~/Android/Sdk"
fi

echo ""

# -------------------------------------------------------
# 3. Check Windows build tools (for Windows builds)
# -------------------------------------------------------
echo "Checking Windows build environment..."

if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ "$(uname -s)" == CYGWIN* ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
    echo "  [OK]  Running on Windows"

    # Check for Visual Studio / Build Tools
    if command -v "where.exe" &>/dev/null; then
        if where.exe cl.exe &>/dev/null 2>&1; then
            echo "  [OK]  MSVC compiler (cl.exe): found"
        else
            echo "  [WARN] MSVC compiler (cl.exe): not found in PATH"
            echo "         Install Visual Studio with 'Desktop development with C++' workload"
            echo "         or install Build Tools for Visual Studio"
        fi
    fi

    # Check for CMake
    check_command "cmake" "CMake" "Install via Visual Studio Installer or https://cmake.org/"
else
    echo "  [INFO] Not running on Windows - Windows build requires Windows host"
fi

echo ""

# -------------------------------------------------------
# 4. Set up PATH additions (if needed)
# -------------------------------------------------------
echo "Verifying PATH..."

FLUTTER_BIN="$(command -v flutter 2>/dev/null || true)"
if [[ -n "${FLUTTER_BIN}" ]]; then
    FLUTTER_DIR="$(dirname "${FLUTTER_BIN}")"
    echo "  Flutter bin: ${FLUTTER_DIR}"

    # Ensure dart is also on PATH (should be via Flutter)
    DART_BIN="$(command -v dart 2>/dev/null || true)"
    if [[ -n "${DART_BIN}" ]]; then
        echo "  Dart bin:    $(dirname "${DART_BIN}")"
    fi

    # Pub cache bin for globally activated packages
    PUB_CACHE="${PUB_CACHE:-${HOME}/.pub-cache}"
    if [[ -d "${PUB_CACHE}/bin" ]]; then
        if echo "${PATH}" | tr ':' '\n' | grep -q "pub-cache/bin"; then
            echo "  Pub cache:   ${PUB_CACHE}/bin (in PATH)"
        else
            echo "  [INFO] Pub cache bin not in PATH. Add to your shell profile:"
            echo "         export PATH=\"\${PATH}:${PUB_CACHE}/bin\""
        fi
    fi
fi

echo ""

# -------------------------------------------------------
# 5. Run flutter doctor
# -------------------------------------------------------
if command -v flutter &>/dev/null; then
    echo "Running flutter doctor..."
    echo ""
    flutter doctor || true
    echo ""
fi

# -------------------------------------------------------
# 6. Install dependencies
# -------------------------------------------------------
if [[ -f "${PROJECT_ROOT}/pubspec.yaml" ]]; then
    echo "Installing project dependencies..."
    cd "${PROJECT_ROOT}"
    flutter pub get
    echo ""
    echo "Dependencies installed."
else
    echo "[INFO] No pubspec.yaml found at project root."
    echo "       Run 'flutter create' or add pubspec.yaml to get started."
fi

echo ""

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
if [[ ${ERRORS} -gt 0 ]]; then
    echo "========================================="
    echo "  Setup completed with ${ERRORS} error(s)"
    echo "  Fix the issues above before building."
    echo "========================================="
    exit 1
else
    echo "========================================="
    echo "  Environment ready"
    echo "========================================="
fi
