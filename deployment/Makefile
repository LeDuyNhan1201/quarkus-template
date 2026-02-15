SHELL:=/bin/bash
VERSION:=1.0.0
MODE:=dev
RUN_ENV:=local

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

.PHONY: prepare
prepare:
	@echo "Preparing environment..."
	@sudo apt-get update -y
	@sudo apt-get install -y make openjdk-17-jdk
	@find scripts/$(RUN_ENV) -type f -name "*.sh" -exec chmod +x {} \;

.PHONY: init
init:
	@echo "Initializing environment..."
	@./scripts/$(RUN_ENV)/init.sh $(MODE)

.PHONY: clean
clean:
	@echo "Cleaning environment..."
	@./scripts/$(RUN_ENV)/clean.sh $(MODE)
