ARG KEYCLOAK_TAG=latest

# ------------------ Build stage (Builder) ------------------
FROM quay.io/keycloak/keycloak:${KEYCLOAK_TAG} AS builder

# Define ENV for build configuration here
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

# Add your custom scripts, themes, providers, or other configurations here
WORKDIR /opt/keycloak
COPY --chown=keycloak:keycloak secrets/certs/ca/ca.crt conf/root.crt
#COPY --chown=keycloak:keycloak keycloak/import data/import
#COPY --chown=keycloak:keycloak secrets/certs/keycloak/keycloak.crt conf/server.crt
#COPY --chown=keycloak:keycloak secrets/certs/keycloak/keycloak.key conf/server.key
RUN /opt/keycloak/bin/kc.sh build

# ------------------ Final stage (Runtime) ------------------
FROM quay.io/keycloak/keycloak:${KEYCLOAK_TAG}
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Define ENV for runtime configuration here if needed

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]