SHELL := /bin/bash

.PHONY: build up down shell status

export IMAGE_NAME = arris/react-native:latest
export CONTAINER_NAME = arris-react-native

build:
	docker build -t ${IMAGE_NAME} .

up:
	docker run --rm -it --privileged \
		--name ${CONTAINER_NAME} \
		-v /dev/bus/usb:/dev/bus/usb \
		-v "$(PWD)"/src:/code \
		-p 19000:19000 \
		-p 19001:19001 \
		-p 5037:5037 \
		${IMAGE_NAME} \
		/bin/bash

down: export CONTAINER_IDS := $(shell docker ps -qa --no-trunc --filter "status=exited")
down:
	docker rm $(CONTAINER_IDS)

clean: export CONTAINER_IDS=$(shell docker ps -qa --no-trunc --filter "status=exited")
clean:
	docker rm $(CONTAINER_IDS)

status:
	docker ps -a
