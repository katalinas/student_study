#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# run_dev.sh - Run the app in development mode
#
# Usage:
#   ./run_dev.sh [--platform <android|windows>]
#
# Defaults to windows on Windows hosts, android otherwise.
# -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS_DIR}/.." && pwd)"

PLATFORM=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--platform <android|windows>]"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

# Auto-detect platform if not specified
if [[ -z "${PLATFORM}" ]]; then
    if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
        PLATFORM="windows"
    else
        PLATFORM="android"
    fi
fi

# Validate platform
if [[ ! "${PLATFORM}" =~ ^(android|windows)$ ]]; then
    echo "Error: --platform must be one of: android, windows"
    exit 1
fi

# Source development environment
ENV_FILE="${OPS_DIR}/environments/dev.env"
if [[ -f "${ENV_FILE}" ]]; then
    echo "Loading dev environment..."
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
fi

cd "${PROJECT_ROOT}"

echo "========================================="
echo "  Development Mode"
echo "  Platform: ${PLATFORM}"
echo "========================================="
echo ""

# Install dependencies
echo "Checking dependencies..."
flutter pub get

echo ""
echo "Starting app on ${PLATFORM} (hot reload enabled)..."
echo "Press 'r' for hot reload, 'R' for hot restart, 'q' to quit."
echo ""

# Build device flags
DEVICE_FLAGS=()
case "${PLATFORM}" in
    windows)
        DEVICE_FLAGS+=("-d" "windows")
        ;;
    android)
        # Let Flutter auto-select the connected Android device
        DEVICE_FLAGS+=("-d" "android")
        ;;
esac

# Run with debug mode (enables hot reload)
flutter run --debug "${DEVICE_FLAGS[@]}"
