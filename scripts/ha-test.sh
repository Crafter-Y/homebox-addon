#!/usr/bin/env bash
# ==============================================================================
# Full Home Assistant development environment for the Homebox addon.
#
# Runs the same HA devcontainer image with Docker-in-Docker, HA Supervisor,
# and the addon source mounted as a local addon — no VS Code required.
#
# Usage:
#   ./scripts/ha-test.sh              # start (or resume) the environment
#   ./scripts/ha-test.sh stop          # stop (data preserved)
#   ./scripts/ha-test.sh shell         # open a shell inside the container
#   ./scripts/ha-test.sh logs          # tail Supervisor logs
#   ./scripts/ha-test.sh destroy       # remove container + volumes (all data lost)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CONTAINER_NAME="homebox-ha-dev"
IMAGE="ghcr.io/home-assistant/devcontainer:3-addons"
HA_PORT=7123
HOMEBOX_PORT=7745
ADDON_MOUNT="/mnt/supervisor/addons/local/homebox-addon"
CONFIG_YAML="${PROJECT_DIR}/homebox/config.yaml"

# ---------- helpers -----------------------------------------------------------

# The "image:" field in config.yaml makes the Supervisor pull pre-built images
# instead of building from the local Dockerfile. Comment it out for local dev
# (official HA recommendation: https://developers.home-assistant.io/docs/apps/testing/).
disable_image_field() {
    if grep -q '^image:' "$CONFIG_YAML" 2>/dev/null; then
        sed -i 's/^image:/#image:/' "$CONFIG_YAML"
        echo "    Commented out 'image:' in config.yaml (enables local build)"
    fi
}

restore_image_field() {
    if grep -q '^#image:' "$CONFIG_YAML" 2>/dev/null; then
        sed -i 's/^#image:/image:/' "$CONFIG_YAML"
        echo "    Restored 'image:' in config.yaml"
    fi
}

wait_for_docker() {
    echo "==> Waiting for Docker daemon inside the container..."
    local tries=0
    while ! docker exec "$CONTAINER_NAME" docker info &>/dev/null 2>&1; do
        tries=$((tries + 1))
        if (( tries > 60 )); then
            echo "ERROR: Docker daemon did not start after 60 s."
            echo "       Check: docker exec $CONTAINER_NAME cat /var/log/dockerd.log"
            exit 1
        fi
        sleep 1
    done
    echo "    Docker daemon ready."
}

start_dockerd() {
    # The devcontainer image includes dockerd but may not auto-start it
    # when launched outside VS Code. Start it if it isn't running.
    docker exec "$CONTAINER_NAME" bash -c '
        if docker info &>/dev/null 2>&1; then
            exit 0
        fi
        echo "Starting dockerd..."
        nohup dockerd &>/var/log/dockerd.log &
    '
}

start_supervisor() {
    echo "==> Starting HA Supervisor..."

    # stty is called during bootstrap but fails without a real terminal
    docker exec "$CONTAINER_NAME" bash -c \
        'printf "#!/bin/sh\nexit 0\n" > /usr/local/bin/stty && chmod +x /usr/local/bin/stty'

    # Check if the Supervisor container is already running (more reliable
    # than pgrep which can self-match inside docker exec).
    if docker exec "$CONTAINER_NAME" \
            docker ps --format '{{.Names}}' 2>/dev/null | grep -q hassio_supervisor; then
        echo "    Supervisor already running."
        return
    fi

    docker exec "$CONTAINER_NAME" bash -c \
        'bash /usr/bin/supervisor_run > /var/log/supervisor_run.log 2>&1 &'
    echo "    Supervisor started."
}

wait_for_ha() {
    echo "==> Waiting for Home Assistant (first start takes 3-5 minutes)..."
    local tries=0
    while ! docker exec "$CONTAINER_NAME" \
            curl -s -o /dev/null -w '' http://localhost:8123 2>/dev/null; do
        tries=$((tries + 1))
        if (( tries > 150 )); then
            echo "ERROR: Home Assistant did not respond after ~10 minutes."
            echo "       Check: ./scripts/ha-test.sh logs"
            exit 1
        fi
        sleep 4
    done
}

print_status() {
    cat <<EOF

  ============================================================
  Home Assistant is ready!

  HA UI:       http://localhost:${HA_PORT}
  Homebox:     http://localhost:${HOMEBOX_PORT}  (after addon is started)

  First-time setup:
    1. Open http://localhost:${HA_PORT} and create an account
    2. Settings → Add-ons → Add-on Store
    3. Find "Homebox" under "Local add-ons" → Install → Start

  After editing addon code, rebuild inside the container:
    ha apps rebuild local_homebox

  Commands:
    ./scripts/ha-test.sh shell     Open a shell in the container
    ./scripts/ha-test.sh logs      Tail Supervisor logs
    ./scripts/ha-test.sh stop      Stop (data preserved)
    ./scripts/ha-test.sh destroy   Remove everything
  ============================================================

EOF
}

# ---------- sub-commands ------------------------------------------------------

cmd_start() {
    disable_image_field

    # Re-use existing container if possible
    if docker container inspect "$CONTAINER_NAME" &>/dev/null 2>&1; then
        local status
        status=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME")
        if [[ "$status" == "running" ]]; then
            echo "Container '${CONTAINER_NAME}' is already running."
            # Ensure Supervisor is up (it doesn't survive a host reboot)
            start_supervisor
            print_status
            return
        fi
        echo "==> Restarting stopped container..."
        docker start "$CONTAINER_NAME"
    else
        echo "==> Creating Home Assistant dev environment..."
        echo "    (pulling image on first run — this may take a while)"
        # MSYS_NO_PATHCONV: prevent Git Bash on Windows from mangling volume paths
        MSYS_NO_PATHCONV=1 docker run -d \
            --name "$CONTAINER_NAME" \
            --privileged \
            -p "${HA_PORT}:8123" \
            -p "${HOMEBOX_PORT}:${HOMEBOX_PORT}" \
            -v homebox-ha-docker:/var/lib/docker \
            -v homebox-ha-supervisor:/mnt/supervisor \
            -v "${PROJECT_DIR}:${ADDON_MOUNT}" \
            -e "WORKSPACE_DIRECTORY=${ADDON_MOUNT}" \
            "$IMAGE" \
            sleep infinity
    fi

    start_dockerd
    wait_for_docker
    start_supervisor
    wait_for_ha
    print_status
}

cmd_stop() {
    echo "==> Stopping container..."
    docker stop "$CONTAINER_NAME"
    restore_image_field
    echo "    Done. Data preserved. Run './scripts/ha-test.sh' to restart."
}

cmd_shell() {
    exec docker exec -it "$CONTAINER_NAME" bash
}

cmd_logs() {
    docker exec "$CONTAINER_NAME" tail -n 200 -f /var/log/supervisor_run.log
}

cmd_destroy() {
    echo "This will delete the container and ALL Home Assistant data (addons, config, database)."
    read -r -p "Are you sure? [y/N] " confirm
    if [[ "${confirm,,}" != "y" ]]; then
        echo "Aborted."
        exit 0
    fi
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    docker volume rm homebox-ha-docker homebox-ha-supervisor 2>/dev/null || true
    restore_image_field
    echo "    Done. Everything removed."
}

# ---------- dispatch ----------------------------------------------------------

case "${1:-start}" in
    start)   cmd_start   ;;
    stop)    cmd_stop    ;;
    shell)   cmd_shell   ;;
    logs)    cmd_logs    ;;
    destroy) cmd_destroy ;;
    *)
        echo "Usage: $0 {start|stop|shell|logs|destroy}"
        exit 1
        ;;
esac
