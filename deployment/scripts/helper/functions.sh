#!/bin/bash

create_client_files() {
  echo "Creating kafka client files"
  rm -rf kafka/configs/*

  envsubst < templates/server.template > kafka/configs/server.properties
  envsubst < templates/client.template > kafka/configs/client.properties
}

create_env_file() {
    # Clean old content before overwrite
    : > .env
    mkdir -p secrets/kafka0
    mkdir -p secrets/postgresql
    : > secrets/kafka0/kafka.secret
    : > secrets/postgresql/postgresql.password

    echo "$CERT_SECRET" >> secrets/kafka0/kafka.secret
    echo "$POSTGRES_TEXT_PASSWORD" >> secrets/postgresql/postgresql.password

    {
      echo CERT_SECRET="$CERT_SECRET"

      echo POSTGRES_USER="$POSTGRES_USER"
      echo POSTGRES_TEXT_PASSWORD="$POSTGRES_TEXT_PASSWORD"

      echo MONGODB_USERNAME="$MONGODB_USERNAME"
      echo MONGODB_PASSWORD="$MONGODB_PASSWORD"

      echo KC_BOOTSTRAP_ADMIN_USERNAME="$KC_BOOTSTRAP_ADMIN_USERNAME"
      echo KC_BOOTSTRAP_ADMIN_PASSWORD="$KC_BOOTSTRAP_ADMIN_PASSWORD"

      # External Kafka library versions
      echo KAFKA_OAUTH_LIB_VERSION="$KAFKA_OAUTH_LIB_VERSION"
      echo NIMBUS_JWT_LIB_VERSION="$NIMBUS_JWT_LIB_VERSION"
      echo PROMETHEUS_JAVAAGENT_VERSION="$PROMETHEUS_JAVAAGENT_VERSION"

      # Kafka advanced configurations
      echo BROKER_HEAP="$BROKER_HEAP"
      echo SCHEMA_HEAP="$SCHEMA_HEAP"
      echo KAFKA_LISTENER_NAME_INTERNAL_SSL_PRINCIPAL_MAPPING_RULES="$KAFKA_LISTENER_NAME_INTERNAL_SSL_PRINCIPAL_MAPPING_RULES"
      echo SSL_CIPHER_SUITES="$SSL_CIPHER_SUITES"

      # IDP configurations
      echo KAFKA_IDP_TOKEN_ENDPOINT="$KAFKA_IDP_TOKEN_ENDPOINT"
      echo KAFKA_IDP_JWKS_ENDPOINT="$KAFKA_IDP_JWKS_ENDPOINT"
      echo KAFKA_IDP_EXPECTED_ISSUER="$KAFKA_IDP_EXPECTED_ISSUER"
      echo KAFKA_IDP_AUTH_ENDPOINT="$KAFKA_IDP_AUTH_ENDPOINT"
      echo KAFKA_IDP_AUTH_DEVICE_ENDPOINT="$KAFKA_IDP_AUTH_DEVICE_ENDPOINT"
      echo KAFKA_SUB_CLAIM_NAME="$KAFKA_SUB_CLAIM_NAME"
      echo KAFKA_SCOPE_CLAIM_NAME="$KAFKA_SCOPE_CLAIM_NAME"
      echo KAFKA_GROUP_CLAIM_NAME="$KAFKA_GROUP_CLAIM_NAME"
      echo KAFKA_EXPECTED_AUDIENCE="$KAFKA_EXPECTED_AUDIENCE"

      # Client configurations
      echo KAFKA_SUPERUSER_CLIENT_ID="$KAFKA_SUPERUSER_CLIENT_ID"
      echo KAFKA_SUPERUSER_CLIENT_SECRET="$KAFKA_SUPERUSER_CLIENT_SECRET"

      echo KAFKA_SR_CLIENT_ID="$KAFKA_SR_CLIENT_ID"
      echo KAFKA_SR_CLIENT_SECRET="$KAFKA_SR_CLIENT_SECRET"

      echo KAFKA_C3_CLIENT_ID="$KAFKA_C3_CLIENT_ID"
      echo KAFKA_C3_CLIENT_SECRET="$KAFKA_C3_CLIENT_SECRET"

      echo KAFKA_SSO_CLIENT_ID="$KAFKA_SSO_CLIENT_ID"
      echo KAFKA_SSO_CLIENT_SECRET="$KAFKA_SSO_CLIENT_SECRET"

      echo KAFKA_BACKEND_CLIENT_ID="$KAFKA_BACKEND_CLIENT_ID"
      echo KAFKA_BACKEND_CLIENT_SECRET="$KAFKA_BACKEND_CLIENT_SECRET"

      echo KAFKA_SSO_SUPER_USER_GROUP="$KAFKA_SSO_SUPER_USER_GROUP"
      echo KAFKA_SSO_USER_GROUP="$KAFKA_SSO_USER_GROUP"

    } >> .env

}

