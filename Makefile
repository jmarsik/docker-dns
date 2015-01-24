.SILENT :
.PHONY : help build clean run stop rm shell

USERNAME:=shabble
APPNAME:=docker-dns
IMAGE:=$(USERNAME)/$(APPNAME)

define docker_run_flags
--hostname='docker-dns' \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(PWD)/dnsmasq.tmpl:/etc/dnsmasq.tmpl \
-e DNS_ENVIRON=dev \
-e DNS_ROOT=docker \
-p 53:53/udp
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
	-docker logs --follow=true  $(APPNAME)

## Stop the container
stop:
	echo "Stopping container $(APPNAME) ..."
	-docker kill $(APPNAME)
	-docker rm $(APPNAME)

## Delete the container
rm:
	echo "Deleting container $(APPNAME) ..."
	-docker rm $(APPNAME)

## Run the container with shell access
explore:
	echo "Running docker image $(IMAGE) as just a shell"
	docker run --rm -it $(docker_run_flags) --entrypoint="/bin/bash" $(IMAGE) -c /bin/bash

shell:
	echo "Running docker shell inside $(APPNAME)..."
	docker exec -it $(APPNAME) /bin/bash

dump:
	docker exec -it $(APPNAME) /bin/cat /etc/dnsmasq.conf | uniq

