#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Configuration
# -------------------------------

MODE="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEPLOYMENT_DIR="$(dirname "$ROOT_DIR")"

ENV_FILE="${ROOT_DIR}/helper/env_config.sh"

# shellcheck source=/helper/env_config.sh
source "${ENV_FILE}"

IMAGE_PREFIX="${NAMESPACE}/${REPOSITORY_NAME}"

# -------------------------------
# Stop & Remove Containers
# -------------------------------

# docker compose -f docker-compose/docker-compose."${MODE}".yml down -v
#docker compose -f docker-compose/docker-compose.yml down -v

# -------------------------------
# Cleanup Files
# -------------------------------

echo "Removing certs and environment files..."

rm -rf "${DEPLOYMENT_DIR}/secrets/"*
rm -f "${DEPLOYMENT_DIR}/.env"

# -------------------------------
# Remove Docker Images
# -------------------------------

docker rmi "${IMAGE_PREFIX}/postgres:${POSTGRES_TAG}" || true
docker rmi "${IMAGE_PREFIX}/keycloak:${KEYCLOAK_TAG}" || true

echo "Cleanup completed successfully."
