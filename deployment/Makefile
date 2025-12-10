SHELL:=/bin/bash
VERSION:=1.0.0
MODE:=dev

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

start:
	@echo "Starting..."
	@sudo chown -R $(shell id -u):$(shell id -g) .
	@sudo chmod +x scripts/*.sh
	@./scripts/start.sh $(MODE)

stop:
	@echo "Stopping..."
	@./scripts/stop.sh $(MODE)
