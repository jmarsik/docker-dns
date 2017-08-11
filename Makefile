.SILENT :
.PHONY : help build clean run stop rm shell

USERNAME:=jmarsik
APPNAME:=dns
IMAGE:=$(USERNAME)/$(APPNAME)

define docker_run_flags
--hostname='dns' \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(PWD)/dnsmasq.tmpl:/etc/dnsmasq.tmpl \
-e DNS_ROOT=docker.local \
-e DNS_ENV=dev \
-e DNS_FORWARDER=8.8.8.8 \
-e DNS_AUTH_TTL=10 \
-e DNS_LOG_QUERIES=1 \
--expose=53/tcp \
--expose=53/udp
endef

all: build

## This help screen
help:
	printf "Available targets:\n\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)


## Build the image
build:
	echo "Building $(IMAGE) docker image..."
# Use Google DNS for DNS queries when building, because Docker itself can be configured
#  to use docker-dns container and it could be unavailable at this moment
	docker --dns=8.8.8.8 build -t $(IMAGE) .

## Remove the image (also stop and delete the container)
clean: stop rm
	echo "Removing $(IMAGE) docker image..."
	docker rmi $(IMAGE)

## Run the container
run:
	echo "Running $(IMAGE) docker image..."
	docker run -d $(docker_run_flags) --name $(APPNAME) $(IMAGE)

logs:
	-docker logs --follow=true $(APPNAME)

## Stop and delete the container
stop:
	echo "Stopping and deleting container $(APPNAME) ..."
	-docker kill $(APPNAME)
	-docker rm $(APPNAME)

## Delete the container
rm:
	echo "Deleting container $(APPNAME) ..."
	-docker rm $(APPNAME)

## Run new container with shell instead of supervisord
explore:
	echo "Running docker image $(IMAGE) as just a shell"
	docker run --rm -it $(docker_run_flags) $(IMAGE) bash

## Enter running container shell to explore it while in operation
shell:
	echo "Running docker shell inside $(APPNAME)..."
	docker exec -it $(APPNAME) /bin/bash

## Show generated dnsmasq.conf
dump:
	docker exec -it $(APPNAME) /bin/cat /etc/dnsmasq.conf | uniq
