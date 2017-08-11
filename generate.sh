#!/bin/bash

echo -e "GET /containers/json HTTP/1.0\r\n" | socat unix-connect:$DOCKER_SOCKET STDIO | sed '1,/^\r$/d' | \
    jq -r 'map(.Id)[]' | \
    { xargs -I {} bash -c 'echo -e "GET /containers/{}/json HTTP/1.0\r\n" | socat unix-connect:$DOCKER_SOCKET STDIO | sed '\''1,/^\r$/d'\''' ; } | \
    jq --compact-output --ascii-output --monochrome-output -s '{Env: {DNS_ROOT: "docker.wh1.fullvent.cz", DNS_ENV: "dev", DNS_LOG_QUERIES: "", DNS_AUTH_TTL: 10, DNS_FORWARDER: "8.8.8.8"}, Containers: map({Hostname: .Config.Hostname, Domainname: .Config.Domainname, NetworkSettings: {IPAddress: .NetworkSettings.IPAddress}, Name: .Name[1:], Image: {Repository: .Config.Image|split("/")[-1:][0]|split(":")[0:1][0]}})}' | \
    python -c 'import jsontemplate,json,sys; print(jsontemplate.FromFile(open('\''/etc/dnsmasq.jsont'\'')).expand(json.load(sys.stdin)));' \
    > /etc/dnsmasq.conf

diff /etc/dnsmasq.conf.old /etc/dnsmasq.conf
cp -f /etc/dnsmasq.conf /etc/dnsmasq.conf.old

supervisorctl restart dnsmasq
