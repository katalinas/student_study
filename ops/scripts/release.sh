#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# release.sh - Create a tagged release with build artifacts
#
# Reads version from pubspec.yaml, creates a git tag,
# builds release artifacts, and generates release notes.
#
# Usage:
#   ./release.sh [--skip-tag] [--skip-build]
# -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS_DIR}/.." && pwd)"
DIST_DIR="${OPS_DIR}/dist"
RELEASE_DIR="${DIST_DIR}/release"

SKIP_TAG=false
SKIP_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-tag)
            SKIP_TAG=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-tag] [--skip-build]"
            echo "  --skip-tag    Skip git tag creation"
            echo "  --skip-build  Skip building artifacts"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

cd "${PROJECT_ROOT}"

# -------------------------------------------------------
# 1. Read version from pubspec.yaml
# -------------------------------------------------------
PUBSPEC_FILE="${PROJECT_ROOT}/pubspec.yaml"
if [[ ! -f "${PUBSPEC_FILE}" ]]; then
    echo "Error: pubspec.yaml not found at ${PUBSPEC_FILE}"
    exit 1
fi

# Extract version line: "version: 1.0.0+1"
VERSION_LINE="$(grep -E '^version:' "${PUBSPEC_FILE}" | head -1)"
if [[ -z "${VERSION_LINE}" ]]; then
    echo "Error: No version field found in pubspec.yaml"
    exit 1
fi

# Parse version (strip build number after +)
FULL_VERSION="$(echo "${VERSION_LINE}" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]')"
SEMVER="$(echo "${FULL_VERSION}" | cut -d'+' -f1)"
TAG_NAME="v${SEMVER}"

echo "========================================="
echo "  Release: ${TAG_NAME}"
echo "  Full version: ${FULL_VERSION}"
echo "========================================="

# -------------------------------------------------------
# 2. Verify clean working tree
# -------------------------------------------------------
if [[ -n "$(git status --porcelain)" ]]; then
    echo ""
    echo "Warning: Working tree has uncommitted changes."
    echo "It is recommended to commit or stash changes before releasing."
    read -r -p "Continue anyway? [y/N] " confirm
    if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
        echo "Release aborted."
        exit 1
    fi
fi

# -------------------------------------------------------
# 3. Create git tag
# -------------------------------------------------------
if [[ "${SKIP_TAG}" == false ]]; then
    if git rev-parse "${TAG_NAME}" &>/dev/null; then
        echo ""
        echo "Error: Tag ${TAG_NAME} already exists."
        echo "Bump the version in pubspec.yaml or use --skip-tag."
        exit 1
    fi

    echo ""
    echo "Creating git tag: ${TAG_NAME}"
    git tag -a "${TAG_NAME}" -m "Release ${TAG_NAME}"
    echo "Tag ${TAG_NAME} created. Push with: git push origin ${TAG_NAME}"
else
    echo ""
    echo "Skipping tag creation (--skip-tag)"
fi

# -------------------------------------------------------
# 4. Build release artifacts
# -------------------------------------------------------
mkdir -p "${RELEASE_DIR}"

if [[ "${SKIP_BUILD}" == false ]]; then
    echo ""
    echo "Building release artifacts..."
    APP_ENV=prod bash "${SCRIPT_DIR}/build.sh" --platform all --mode release

    # Move artifacts to release directory
    for artifact in "${DIST_DIR}"/student-study-*; do
        if [[ -e "${artifact}" ]]; then
            mv "${artifact}" "${RELEASE_DIR}/"
        fi
    done

    # Rename with version
    for file in "${RELEASE_DIR}"/student-study-*; do
        if [[ -f "${file}" ]]; then
            local_name="$(basename "${file}")"
            versioned_name="${local_name/student-study/student-study-${SEMVER}}"
            if [[ "${local_name}" != "${versioned_name}" ]]; then
                mv "${file}" "${RELEASE_DIR}/${versioned_name}"
            fi
        fi
    done
else
    echo ""
    echo "Skipping build (--skip-build)"
fi

# -------------------------------------------------------
# 5. Generate release notes
# -------------------------------------------------------
RELEASE_NOTES="${RELEASE_DIR}/RELEASE_NOTES.md"

echo ""
echo "Generating release notes..."

# Find the previous tag
PREVIOUS_TAG="$(git tag --sort=-version:refname | grep -v "^${TAG_NAME}$" | head -1 || true)"

{
    echo "# Release ${TAG_NAME}"
    echo ""
    echo "**Date:** $(date +%Y-%m-%d)"
    echo ""

    if [[ -n "${PREVIOUS_TAG}" ]]; then
        echo "## Changes since ${PREVIOUS_TAG}"
        echo ""
        git log "${PREVIOUS_TAG}..HEAD" --pretty=format:"- %s (%h)" --no-merges 2>/dev/null || true
    else
        echo "## Changes"
        echo ""
        git log --pretty=format:"- %s (%h)" --no-merges -20 2>/dev/null || true
    fi

    echo ""
    echo ""
    echo "## Artifacts"
    echo ""
    for file in "${RELEASE_DIR}"/*; do
        if [[ -f "${file}" && "$(basename "${file}")" != "RELEASE_NOTES.md" ]]; then
            local_size="$(wc -c < "${file}" 2>/dev/null | tr -d '[:space:]')"
            local_size_mb="$(echo "scale=2; ${local_size} / 1048576" | bc 2>/dev/null || echo "unknown")"
            echo "- \`$(basename "${file}")\` (${local_size_mb} MB)"
        fi
    done

    echo ""
    echo "## Checksums"
    echo ""
    echo '```'
    for file in "${RELEASE_DIR}"/*; do
        if [[ -f "${file}" && "$(basename "${file}")" != "RELEASE_NOTES.md" ]]; then
            if command -v sha256sum &>/dev/null; then
                sha256sum "${file}" | awk '{print $1 "  " FILENAME}' FILENAME="$(basename "${file}")"
            elif command -v shasum &>/dev/null; then
                shasum -a 256 "${file}" | awk '{print $1 "  " FILENAME}' FILENAME="$(basename "${file}")"
            elif command -v certutil.exe &>/dev/null; then
                local_hash="$(certutil.exe -hashfile "${file}" SHA256 2>/dev/null | sed -n '2p' | tr -d '[:space:]')"
                echo "${local_hash}  $(basename "${file}")"
            fi
        fi
    done
    echo '```'
} > "${RELEASE_NOTES}"

echo ""
echo "========================================="
echo "  Release ${TAG_NAME} prepared"
echo "========================================="
echo ""
echo "Artifacts:     ${RELEASE_DIR}/"
ls -lh "${RELEASE_DIR}/" 2>/dev/null || true
echo ""
echo "Release notes: ${RELEASE_NOTES}"
echo ""
echo "Next steps:"
echo "  1. Review release notes: cat ${RELEASE_NOTES}"
echo "  2. Push tag: git push origin ${TAG_NAME}"
echo "  3. GitHub will trigger the release workflow automatically"
