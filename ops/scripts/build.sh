#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# build.sh - Cross-platform Flutter build script
#
# Usage:
#   ./build.sh --platform <android|windows|all> --mode <debug|release>
#
# Outputs artifacts to ops/dist/
# -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS_DIR}/.." && pwd)"
DIST_DIR="${OPS_DIR}/dist"

PLATFORM="all"
MODE="release"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --platform <android|windows|all> --mode <debug|release>"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ ! "$PLATFORM" =~ ^(android|windows|all)$ ]]; then
    echo "Error: --platform must be one of: android, windows, all"
    exit 1
fi

if [[ ! "$MODE" =~ ^(debug|release)$ ]]; then
    echo "Error: --mode must be one of: debug, release"
    exit 1
fi

# Ensure dist directory exists
mkdir -p "${DIST_DIR}"

# Source environment if APP_ENV is set
APP_ENV="${APP_ENV:-dev}"
ENV_FILE="${OPS_DIR}/environments/${APP_ENV}.env"
if [[ -f "${ENV_FILE}" ]]; then
    echo "Loading environment: ${APP_ENV}"
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
fi

cd "${PROJECT_ROOT}"

echo "========================================="
echo "  Flutter Build"
echo "  Platform: ${PLATFORM}"
echo "  Mode:     ${MODE}"
echo "  Env:      ${APP_ENV}"
echo "========================================="

# Install dependencies
echo ""
echo "Installing dependencies..."
flutter pub get

build_android() {
    echo ""
    echo "--- Building Android APK (${MODE}) ---"

    local build_flags=()
    if [[ "${MODE}" == "release" ]]; then
        build_flags+=("--release")
    else
        build_flags+=("--debug")
    fi

    flutter build apk "${build_flags[@]}"

    # Copy artifact to dist
    local apk_dir="build/app/outputs/flutter-apk"
    if [[ "${MODE}" == "release" ]]; then
        local apk_file="${apk_dir}/app-release.apk"
    else
        local apk_file="${apk_dir}/app-debug.apk"
    fi

    if [[ -f "${apk_file}" ]]; then
        cp "${apk_file}" "${DIST_DIR}/student-study-${MODE}.apk"
        echo "Android APK copied to: ${DIST_DIR}/student-study-${MODE}.apk"
    else
        echo "Warning: Expected APK not found at ${apk_file}"
        # Try to find any APK in the output directory
        local found_apk
        found_apk="$(find "${apk_dir}" -name "*.apk" -print -quit 2>/dev/null || true)"
        if [[ -n "${found_apk}" ]]; then
            cp "${found_apk}" "${DIST_DIR}/student-study-${MODE}.apk"
            echo "Android APK copied to: ${DIST_DIR}/student-study-${MODE}.apk"
        else
            echo "Error: No APK found after build."
            return 1
        fi
    fi
}

build_windows() {
    echo ""
    echo "--- Building Windows executable (${MODE}) ---"

    local build_flags=()
    if [[ "${MODE}" == "release" ]]; then
        build_flags+=("--release")
    else
        build_flags+=("--debug")
    fi

    flutter build windows "${build_flags[@]}"

    # Copy artifact to dist
    local win_dir="build/windows/x64/runner"
    if [[ "${MODE}" == "release" ]]; then
        local win_build="${win_dir}/Release"
    else
        local win_build="${win_dir}/Debug"
    fi

    if [[ -d "${win_build}" ]]; then
        local zip_name="student-study-windows-${MODE}.zip"
        # Use powershell for zip on Windows (Git Bash compatible)
        if command -v powershell.exe &>/dev/null; then
            powershell.exe -NoProfile -Command \
                "Compress-Archive -Path '${win_build}/*' -DestinationPath '${DIST_DIR}/${zip_name}' -Force"
        elif command -v zip &>/dev/null; then
            (cd "${win_build}" && zip -r "${DIST_DIR}/${zip_name}" .)
        else
            # Fallback: copy the directory
            mkdir -p "${DIST_DIR}/student-study-windows-${MODE}"
            cp -r "${win_build}/"* "${DIST_DIR}/student-study-windows-${MODE}/"
            echo "Windows build copied to: ${DIST_DIR}/student-study-windows-${MODE}/"
            return 0
        fi
        echo "Windows build archived to: ${DIST_DIR}/${zip_name}"
    else
        echo "Error: Windows build output not found at ${win_build}"
        return 1
    fi
}

# Execute builds
if [[ "${PLATFORM}" == "android" ]] || [[ "${PLATFORM}" == "all" ]]; then
    build_android
fi

if [[ "${PLATFORM}" == "windows" ]] || [[ "${PLATFORM}" == "all" ]]; then
    build_windows
fi

echo ""
echo "Build complete. Artifacts in: ${DIST_DIR}/"
ls -lh "${DIST_DIR}/" 2>/dev/null || true
