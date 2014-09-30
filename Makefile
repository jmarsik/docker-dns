.SILENT :
.PHONY : build clean run shell

USERNAME:=ncarlier
APPNAME:=docker-dns
IMAGE:=$(USERNAME)/$(APPNAME)

define docker_run_flags
--privileged \
-v /var/run/docker.sock:/var/run/docker.sock \
-p 53:53/udp
endef

all: build

build:
	echo "Building $(IMAGE) docker image..."
	sudo docker build --rm -t $(IMAGE) .

clean:
	echo "Removing $(IMAGE) docker image..."
	sudo docker rmi $(IMAGE)

run:
	echo "Running $(IMAGE) docker image..."
	sudo docker run -d $(docker_run_flags) --name $(APPNAME) $(IMAGE)

shell:
	echo "Running $(IMAGE) docker image with shell access..."
	sudo docker run --rm -it $(docker_run_flags) --entrypoint="/bin/bash" $(IMAGE) -c /bin/bash

