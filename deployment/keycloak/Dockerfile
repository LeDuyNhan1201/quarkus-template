ARG KEYCLOAK_TAG=latest
FROM quay.io/keycloak/keycloak:${KEYCLOAK_TAG}

COPY --chown=keycloak:keycloak secrets/certs/ca/ca.crt /etc/ssl/certs/root.crt
#COPY --chown=keycloak:keycloak secrets/certs/keycloak/keycloak.crt /etc/ssl/certs/server.crt
#COPY --chown=keycloak:keycloak secrets/certs/keycloak/keycloak.key /etc/ssl/certs/server.key
#
#RUN chmod 600 /etc/ssl/certs/server.key

RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true