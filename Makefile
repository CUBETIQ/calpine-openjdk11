DOCKER_IMAGE=cubetiq/calpine-openjdk11
DOCKER_IMAGE_NAME=${DOCKER_IMAGE}:jdk11u

build:
	@echo 'Starting docker build'
	docker build . -t ${DOCKER_IMAGE}
	
	@echo 'Starting docker push'
	docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_NAME}
	docker push ${DOCKER_IMAGE}
	docker push ${DOCKER_IMAGE_NAME}

.PHONY:build