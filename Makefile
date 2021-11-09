DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

image:
	docker build -t chefbe/classandjazz .

image.push:
	docker push chefbe/classandjazz

up:
	docker run --rm -p 3000:3000 chefbe/classandjazz

tests:
	bundle exec rake test
