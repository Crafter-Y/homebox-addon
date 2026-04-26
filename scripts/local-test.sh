#!/usr/bin/env bash
# ==============================================================================
# Local test runner for the Homebox Home Assistant addon.
#
# Builds the addon Docker image and runs it standalone (no HA Supervisor needed).
# The Homebox web UI will be available at http://localhost:<PORT> (default 7745).
# The nginx ingress proxy is automatically disabled (it requires the Supervisor).
#
# Usage:
#   ./scripts/local-test.sh              # build & run on port 7745
#   ./scripts/local-test.sh 8080         # build & run on port 8080
#   ./scripts/local-test.sh --build-only # just build, don't run
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="homebox-addon-local"
CONTAINER_NAME="homebox-addon-test"
OPTIONS_FILE="${SCRIPT_DIR}/options.json"
DATA_DIR="${PROJECT_DIR}/test-data"
PORT="${1:-7745}"
BUILD_ONLY=false

if [[ "${1:-}" == "--build-only" ]]; then
    BUILD_ONLY=true
fi

# --- Build -------------------------------------------------------------------
echo "==> Building addon image..."
docker build \
    --build-arg BUILD_FROM=ghcr.io/hassio-addons/base:20.1.0 \
    -t "$IMAGE_NAME" \
    "${PROJECT_DIR}/homebox"

if $BUILD_ONLY; then
    echo "==> Build complete. Image: ${IMAGE_NAME}"
    exit 0
fi

# --- Prepare data & bashio cache ----------------------------------------------
mkdir -p "$DATA_DIR"

# bashio::config() fetches options via the Supervisor API, which is unavailable
# outside Home Assistant.  Pre-seeding the bashio cache file makes every
# bashio::config call return values from options.json without hitting the API.
CACHE_DIR="${DATA_DIR}/.bashio-cache"
mkdir -p "$CACHE_DIR"
cp "$OPTIONS_FILE" "$CACHE_DIR/addons.self.options.config.cache"

# --- Run ----------------------------------------------------------------------
echo ""
echo "==> Starting Homebox addon container"
echo "    Image:     ${IMAGE_NAME}"
echo "    Port:      http://localhost:${PORT}"
echo "    Data dir:  ${DATA_DIR}"
echo "    Options:   ${OPTIONS_FILE}"
echo ""
echo "    The nginx ingress proxy is disabled (expected outside Home Assistant)."
echo "    Press Ctrl+C to stop."
echo ""

# MSYS_NO_PATHCONV: prevent Git Bash on Windows from mangling volume paths
MSYS_NO_PATHCONV=1 docker run --rm -it \
    --name "$CONTAINER_NAME" \
    -p "${PORT}:7745" \
    -v "${DATA_DIR}:/data" \
    -v "${OPTIONS_FILE}:/data/options.json:ro" \
    -v "${CACHE_DIR}:/tmp/.bashio" \
    "$IMAGE_NAME"
