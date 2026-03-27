# Ops - Build, Deploy & Release Management

This directory contains all operational tooling for the Student Study Flutter application,
targeting **Windows** and **Android** platforms.

## Directory Structure

```
ops/
  Makefile              # Common command shortcuts
  scripts/
    build.sh            # Cross-platform build script
    release.sh          # Versioned release workflow
    setup_env.sh        # Environment prerequisite checks
    run_dev.sh          # Development runner with hot reload
  environments/
    dev.env             # Development environment variables
    staging.env         # Staging environment variables
    prod.env            # Production environment variables (no secrets)
  docker/
    Dockerfile.build    # CI build environment for Android
  dist/                 # Build output directory (gitignored except .gitkeep)
```

## Quick Start

```bash
# 1. Verify prerequisites (Flutter, Dart, Android SDK)
make setup

# 2. Run in development mode (defaults to Windows on Windows, Android otherwise)
make dev

# 3. Build release artifacts
make build-all

# 4. Create a tagged release
make release
```

## Makefile Targets

| Target            | Description                              |
|-------------------|------------------------------------------|
| `make dev`        | Run app in development mode (hot reload) |
| `make build-android` | Build Android APK (release mode)      |
| `make build-windows` | Build Windows executable (release mode) |
| `make build-all`  | Build both Android and Windows           |
| `make test`       | Run all tests                            |
| `make lint`       | Run `dart analyze`                       |
| `make clean`      | Remove build artifacts and dist/         |
| `make release`    | Tag current version and build release    |
| `make setup`      | Check prerequisites and install deps     |

## Environment Configuration

Environment variables are stored in `ops/environments/`. The build and run
scripts source the appropriate `.env` file based on the `--env` flag or
`APP_ENV` variable. Defaults to `dev`.

**Never commit secrets.** The `prod.env` file contains only non-sensitive
configuration. Secrets must be injected via CI variables or a secret manager.

## CI/CD

GitHub Actions workflows live in `.github/workflows/`:

- **ci.yml** -- Runs on every push to `main` and on pull requests. Executes
  lint, test, and build jobs for both platforms.
- **release.yml** -- Triggered by version tags (`v*`). Builds release artifacts
  and publishes a GitHub Release with APK and Windows zip attached.

## Scripts

All shell scripts use `#!/usr/bin/env bash` with `set -euo pipefail` and are
designed to work in Git Bash on Windows as well as native Linux/macOS shells.
