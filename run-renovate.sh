#!/bin/sh
set -eu

RUNNER_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
ENV_FILE="${RUNNER_DIR}/renovate.env"
CACHE_DIR="${RUNNER_DIR}/cache"
LOG_DIR="${RUNNER_DIR}/logs"
CONTAINER_NAME="renovate"

if command -v docker >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker)"
elif [ -x /usr/local/bin/docker ]; then
    DOCKER_BIN="/usr/local/bin/docker"
else
    echo "Docker executable not found" >&2
    exit 1
fi

if "${DOCKER_BIN}" compose version >/dev/null 2>&1; then
    compose() {
        "${DOCKER_BIN}" compose "$@"
    }
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_BIN="$(command -v docker-compose)"
    compose() {
        "${DOCKER_COMPOSE_BIN}" "$@"
    }
else
    echo "Docker Compose not found" >&2
    exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
    echo "Missing ${ENV_FILE}; copy renovate.env.example and add the token" >&2
    exit 1
fi

mkdir -p "${CACHE_DIR}" "${LOG_DIR}"

LOG_FILE="${LOG_DIR}/renovate-$(date +%F).log"
exec >>"${LOG_FILE}" 2>&1

echo "[$(date -Iseconds)] Starting Renovate"

cd "${RUNNER_DIR}"

# Deploy reviewed changes merged into the runner repository.
if git remote get-url origin >/dev/null 2>&1; then
    revision_before="$(git rev-parse --verify HEAD 2>/dev/null || true)"
    git pull --ff-only
    revision_after="$(git rev-parse --verify HEAD 2>/dev/null || true)"

    if [ "${revision_before}" != "${revision_after}" ]; then
        echo "[$(date -Iseconds)] Runner updated; restarting"
        exec /bin/sh "${RUNNER_DIR}/run-renovate.sh" "$@"
    fi
fi

# A fixed name prevents overlapping Task Scheduler runs.
if "${DOCKER_BIN}" container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
    echo "Container ${CONTAINER_NAME} already exists; skipping this run"
    exit 0
fi

compose pull renovate

if compose run --rm --name "${CONTAINER_NAME}" renovate; then
    status=0
else
    status=$?
fi

echo "[$(date -Iseconds)] Renovate finished with status ${status}"
exit "${status}"
