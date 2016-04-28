
IMAGE_NAME = jubicoy/postgresql94-jessie

build:
	docker build -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)
.PHONY: push
