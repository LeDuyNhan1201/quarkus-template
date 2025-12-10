#!/bin/bash
set -euo pipefail

mode=${1:-"dev"}

export CA_NAME="BenRootCA"
export SUBJ_C="VN"
export SUBJ_ST="BinhTriDong"
export SUBJ_L="HCM"
export SUBJ_O="SGU"
export SUBJ_OU="Dev"

export SECRETS_DIR="secrets"
export CERTS_DIR="$SECRETS_DIR/certs"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

env_file="${DIR}/helper/env_config.sh"
echo "Processing $env_file"

source "$env_file"
source "${DIR}/helper/functions.sh"
source "${DIR}/helper/generate_certs.sh"

create_client_files
create_env_file

generate_root_ca
generate_cert_with_keystore_and_truststore "keycloak" "keycloak"
generate_cert_with_keystore_and_truststore "kafka1" "kafka1"