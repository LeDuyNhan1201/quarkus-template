SHELL:=/bin/bash
VERSION:=1.0.0
MODE:=dev
RUN_ENV:=local
KEYCLOAK_HOSTNAME:=keycloak.leduynhan1201.dev

dev-auth:
	docker exec -it -uroot auth-service bash -c 'cd /app && ./gradlew quarkusDev -DdebugHost=0.0.0.0 -DskipTests';

build-images:
	docker build -f ../../src/auth/src/main/docker/Dockerfile.builder -t quarkus/auth-builder ../..
	docker build -f ../../src/concert/src/main/docker/Dockerfile.builder -t quarkus/concert-builder ../..
	docker build -f ../../src/booking/src/main/docker/Dockerfile.builder -t quarkus/booking-builder ../..

remove-images:
	docker rmi quarkus/auth-builder
	docker rmi quarkus/concert-builder
	docker rmi quarkus/booking-builder

# ===== Default values =====
REALM ?=
CONTAINER ?= keycloak0
EXPORT_DIR ?= /opt/keycloak/data/export
LOG_LEVEL ?= info

# optional
USERS_PER_FILE ?=

# ===== Validate =====
check-realm:
	@if [ -z "$(REALM)" ]; then \
		echo "REALM is required. Use: make export-realm REALM=myrealm"; \
		exit 1; \
	fi

# ===== Export realm =====
export-realm: check-realm
	@echo "Exporting realm $(REALM)..."
	@docker exec $(CONTAINER) /opt/keycloak/bin/kc.sh export \
		--realm $(REALM) \
		--dir $(EXPORT_DIR) \
		$(if $(USERS_PER_FILE),--users different_files --users-per-file $(USERS_PER_FILE),--users realm_file) \
		--log-level $(LOG_LEVEL)
	@echo "Done."

.PHONY: prepare
prepare:
	@echo "Preparing environment..."
	@sudo apt-get update -y
	@sudo apt-get install -y make openjdk-17-jdk
	@find scripts/$(RUN_ENV) -type f -name "*.sh" -exec chmod +x {} \;

renew-certs:
	@if [ -z "$(SERVER_NAME)" ]; then \
		echo "SERVER_NAME is required. Use: make renew-certs SERVER_NAME=kafka"; \
		exit 1; \
	fi
	@echo "Generating $(SERVER_NAME) certificates..."
	@./scripts/$(RUN_ENV)/renew_certs.sh $(MODE) $(SERVER_NAME)

rebuild-images:
	@echo "Rebuild local images..."
	@./scripts/$(RUN_ENV)/rebuild_images.sh $(MODE)

.PHONY: init
init:
	@echo "Initializing environment..."
	@./scripts/$(RUN_ENV)/init.sh $(MODE)
	@sudo cp secrets/certs/ca/ca.crt /usr/local/share/ca-certificates/ldnhanCA.crt
	@sudo update-ca-certificates

.PHONY: clean
clean:
	@echo "Cleaning all..."
	@./scripts/$(RUN_ENV)/clean.sh $(MODE)

.PHONY: start
start:
	@echo "Starting containers..."
	@./scripts/$(RUN_ENV)/start.sh $(MODE)

.PHONY: stop
stop:
	@echo "Stopping containers..."
	@./scripts/$(RUN_ENV)/stop.sh $(MODE)

check-connect:
	@openssl s_client -connect $(KEYCLOAK_HOSTNAME):443 -servername $(KEYCLOAK_HOSTNAME)
