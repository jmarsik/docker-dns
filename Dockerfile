FROM debian:jessie
MAINTAINER Jakub Marsik <https://github.com/jmarsik/docker-dns>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl socat dnsmasq psmisc supervisor python-pip jq
RUN pip install jsontemplate

ENV DOCKERGEN_VERSION 0.3.9
ENV DOCKERGEN_URL https://github.com/jwilder/docker-gen/releases/download/$DOCKERGEN_VERSION/docker-gen-linux-amd64-$DOCKERGEN_VERSION.tar.gz
RUN curl -L -k "$DOCKERGEN_URL" | tar -C /usr/local/bin -xvz

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/docker-gen.conf
ADD generate.sh /
RUN touch /etc/dnsmasq.conf.old

# used by generate.sh script for communication with Docker by using socat
ENV DOCKER_SOCKET /var/run/docker.sock
# used by docker-gen instead of command line parameter -endpoint
ENV DOCKER_HOST unix://$DOCKER_SOCKET

# default values of configuration environment variables
ENV DNS_ROOT docker.local
ENV DNS_ENV ""
ENV DNS_FORWARDER 8.8.8.8
ENV DNS_AUTH_TTL 0
ENV DNS_LOG_QUERIES 0

ADD dnsmasq.tmpl /etc/
ADD dnsmasq.jsont /etc/

EXPOSE 53/tcp
EXPOSE 53/udp

CMD ["/usr/bin/supervisord", "--configuration", "/etc/supervisor/supervisord.conf", "--nodaemon", "--logfile", "/dev/stdout", "--logfile_maxbytes", "0"]
