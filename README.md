# DNS server for Docker environment

Simple dynamic DNS server for Docker environment (mainly those with only one host) with single zone automatically generated from information about running containers by [docker-gen](https://github.com/jwilder/docker-gen).

Can be used as very simple implementation of service discovery. Still probably better than Docker links mechanism, because they are everything but dynamic :)

Usage:

```
docker run \
  -p 172.17.42.1:53:53 \
  -p 172.17.42.1:53:53/udp \
  -e DNS_ROOT=docker.local \
  -e DNS_ENV=
  fullvent/docker-dns
```

Environment variables:

- DNS_ROOT - domain name used for generated DNS zone, default is _docker.local_
- DNS_ENV - environment part of generated DNS zone records, default is empty

Multiple records are generated for each running container:

- \<container name\>
- \<container name\>.\<root domain\>
- \<container hostname including domain\>
- when DNS_ENV environment variable is specified:
-- \<container name\>.\<environment\>.\<root domain\>
-- \<container name\>.\<container image repository\>.\<environment\>.\<root domain\>
