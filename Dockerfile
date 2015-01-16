# Docker Register image.
#
# VERSION 0.0.1

FROM debian:jessie

MAINTAINER Nicolas Carlier <https://github.com/ncarlier>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl dnsmasq psmisc supervisor dnsutils

ENV DOCKERGEN_URL https://github.com/jwilder/docker-gen/releases/download/0.3.3/docker-gen-linux-amd64-0.3.3.tar.gz
RUN (cd /tmp && curl -L -o docker-gen.tgz $DOCKERGEN_URL && tar -C /usr/local/bin -xvzf docker-gen.tgz)

ADD dnsmasq.tmpl /etc/dnsmasq.tmpl

ENV DOCKER_HOST unix:///var/run/docker.sock
run echo moo
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/docker-gen.conf

EXPOSE 53/udp

ENTRYPOINT  ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

CMD ["-n", "-l -"]
