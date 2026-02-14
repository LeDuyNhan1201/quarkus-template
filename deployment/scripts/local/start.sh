#!/bin/bash
set -euo pipefail

# -------------------------------
# Configuration
# -------------------------------

MODE="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ENV_FILE="${SCRIPT_DIR}/helper/env_config.sh"
FUNCTIONS_FILE="${SCRIPT_DIR}/helper/functions.sh"
CERT_SCRIPT="${SCRIPT_DIR}/helper/generate_certs.sh"

# -------------------------------
# Load Environment & Helpers
# -------------------------------

source "${ENV_FILE}"
source "${FUNCTIONS_FILE}"
source "${CERT_SCRIPT}"

# -------------------------------
# Generate Environment & Certificates
# -------------------------------

create_client_files
create_env_file

generate_root_ca
generate_cert_with_keystore_and_truststore "postgresql" "postgres" "ldnhan.${MODE}.postgresql"
generate_cert_with_keystore_and_truststore "keycloak" "keycloak" "ldnhan.${MODE}.keycloak"
generate_cert_with_keystore_and_truststore "kafka0" "kafka0" "ldnhan.${MODE}.kafka0"

# -------------------------------
# Docker Image Build
# -------------------------------

IMAGE_PREFIX="${NAMESPACE}/${REPOSITORY_NAME}"

docker build \
  --build-arg POSTGRES_TAG="${POSTGRES_TAG}" \
  -f postgresql/Dockerfile \
  -t "${IMAGE_PREFIX}/postgres:${POSTGRES_TAG}" \
  .

docker build \
  --build-arg KEYCLOAK_TAG="${KEYCLOAK_TAG}" \
  -f keycloak/Dockerfile \
  -t "${IMAGE_PREFIX}/keycloak:${KEYCLOAK_TAG}" \
  .

# -------------------------------
# Start Containers
# -------------------------------

# docker compose -f docker-compose/docker-compose."${MODE}".yml up -d
docker compose -f docker-compose/docker-compose.yml up -d