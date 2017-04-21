# Gantry crane
Toolset for easy setup private Docker Registry

## Overview
Granty crane combines six awsome tools to easy create your own private docker registry:
* [Docker Registry V2](https://hub.docker.com/_/registry/) which hosts your docker images
* [Portus](http://port.us.org/) registry authentication service (including LDAP) and registry UI
* [Portainer](http://portainer.io/) lightweight container management UI
* [Nginx](https://hub.docker.com/_/nginx/) as reverse proxy
* [Docker-gen](https://github.com/jwilder/docker-gen) which automatically generates reverse proxy configs to route requests from the host to containers
* [letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) a lightweight companion container which allows the creation/renewal of [Let's Encrypt](https://letsencrypt.org/) certificates automatically

## Requirements
* [Docker engine](https://docs.docker.com/engine/installation) and [Docker compose](https://docs.docker.com/compose/install/) installed on host
* Public available domain names for docker registry, registry UI and container management service
* Host should be accessible from the internet to recieve [Let's Encrypt](https://letsencrypt.org/) ssl certificates

## Usage
* Run prepare script which creates all nessesary data directories, configuration files and docker compose files
```
./install.sh --nginx-http=80 --nginx-https=443 \
             --data-root=/path/to/data \
             --cert-owner-email=someone@example.com \
             --portainer-fqdn=portainer.example.com \
             --registry-fqdn=registry.example.com \
             --registry-ui-fqdn=hub.example.com
```
* Navigate to `/path/to/data/compose/nginx` and run `docker-compose up -d` to start nginx reverse proxy with Let's Encrypt SSL support
* Navigate to `/path/to/data/compose/registry` and run `docker-compose up -d` to start Docker Registry with Portus UI and authentication service and Portainer docker management UI

## License
[MIT](https://github.com/kyr0s/gantry-crane/blob/master/LICENSE)
