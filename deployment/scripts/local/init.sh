#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Configuration
# -------------------------------

MODE="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENV_FILE="${ROOT_DIR}/helper/env_config.sh"
FUNCTIONS_FILE="${ROOT_DIR}/helper/functions.sh"
CERT_SCRIPT="${ROOT_DIR}/helper/generate_certs.sh"
KEYPAIR_SCRIPT="${ROOT_DIR}/helper/generate_keypair.sh"

# -------------------------------
# Load Environment & Helpers
# -------------------------------

# shellcheck source=/helper/env_config.sh
source "${ENV_FILE}"
# shellcheck source=/helper/functions.sh
source "${FUNCTIONS_FILE}"
# shellcheck source=/helper/generate_certs.sh
source "${CERT_SCRIPT}"
# shellcheck source=/helper/generate_keypair.sh
source "${KEYPAIR_SCRIPT}"

# -------------------------------
# Generate Environment & Certificates
# -------------------------------

create_client_files
create_env_file

generate_root_ca
generate_cert_with_keystore_and_truststore "postgres" "postgres" "ldnhan.${MODE}.postgres"
generate_cert_with_keystore_and_truststore "keycloak" "keycloak" "ldnhan.${MODE}.keycloak"
generate_cert_with_keystore_and_truststore "kafka0" "kafka0" "ldnhan.${MODE}.kafka0"

generate_jwt_keypair kafka kafka true

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
# docker compose -f docker-compose/docker-compose.yml up -d