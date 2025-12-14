#!/bin/bash
set -euo pipefail

mode=${1:-"dev"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
env_file="${DIR}/helper/env_config.sh"
source "$env_file"

#docker compose -f docker-compose/docker-compose."${mode}".yml down -v
docker compose -f docker-compose/docker-compose.yml down -v

echo "Removing certs..."
sudo rm -rf secrets/*
sudo rm -rf .env

#docker rmi veg-store/backend-builder:"${BACKEND_VERSION}"
docker rmi ldnhan/postgres:"$POSTGRES_TAG"
docker rmi ldnhan/keycloak:"$KEYCLOAK_TAG"

echo "Done."
