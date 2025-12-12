#!/bin/bash
set -euo pipefail

mode=${1:-"dev"}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
env_file="${DIR}/helper/env_config.sh"

source "$env_file"
source "${DIR}/helper/functions.sh"
source "${DIR}/helper/generate_certs.sh"

create_client_files
create_env_file

generate_root_ca
generate_cert_with_keystore_and_truststore "postgresql" "postgresql"
generate_cert_with_keystore_and_truststore "keycloak" "keycloak"
generate_cert_with_keystore_and_truststore "kafka1" "kafka1"

sudo chown root:root secrets/certs/postgresql/postgresql.key
sudo chmod 600 secrets/certs/postgresql/postgresql.key

#docker compose -f docker-compose/docker-compose."${mode}".yml up -d
docker compose -f docker-compose/docker-compose.yml up postgres -d