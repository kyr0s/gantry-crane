#!/bin/bash

for i in "$@"
do
case $i in
    --nginx-http=*)
    NGINX_HTTP="${i#*=}"
    shift
    ;;
    --nginx-https=*)
    NGINX_HTTPS="${i#*=}"
    shift
    ;;
    --data-root=*)
    DATA_ROOT="${i#*=}"
    shift
    ;;
    --cert-owner-email=*)
    CERT_OWNER_EMAIL="${i#*=}"
    shift
    ;;
    --portainer-fqdn=*)
    PORTAINER_FQDN="${i#*=}"
    shift
    ;;
    --registry-fqdn=*)
    REGISTRY_FQDN="${i#*=}"
    shift
    ;;
    --registry-ui-fqdn=*)
    REGISTRY_UI_FQDN="${i#*=}"
    shift
    ;;
    --default)
    DEFAULT=YES
    shift # just a sample past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

NGINX_PROXY_NETWORK='nginx-proxy-'"$(openssl rand -hex 12)"
PORTUS_SECRET_KEY_BASE=$(openssl rand -hex 64)
PORTUS_PASSWORD=$(openssl rand -hex 64)

rm -rf $DATA_ROOT

mkdir -p $DATA_ROOT/templates
mkdir -p $DATA_ROOT/certs
mkdir -p $DATA_ROOT/mariadb
mkdir -p $DATA_ROOT/nginx/certs
mkdir -p $DATA_ROOT/nginx/conf.d
mkdir -p $DATA_ROOT/nginx/html
mkdir -p $DATA_ROOT/nginx/templates
mkdir -p $DATA_ROOT/nginx/vhost.d
mkdir -p $DATA_ROOT/portainer
mkdir -p $DATA_ROOT/portus
mkdir -p $DATA_ROOT/registry
mkdir -p $DATA_ROOT/compose/nginx
mkdir -p $DATA_ROOT/compose/registry

# Copying template for processing
cp docker-compose_nginx.yml $DATA_ROOT/templates/docker-compose_nginx.yml
cp docker-compose_registry.yml $DATA_ROOT/templates/docker-compose_registry.yml
cp registry.yml $DATA_ROOT/templates/registry.yml
cp portus.yml $DATA_ROOT/templates/portus.yml

# replacing template values  
sed -i 's|{{nginx-http}}|'"${NGINX_HTTP}"'|g; s|{{nginx-https}}|'"${NGINX_HTTPS}"'|g; s|{{nginx-proxy-network}}|'"${NGINX_PROXY_NETWORK}"'|g' $DATA_ROOT/templates/*
sed -i 's|{{data-root}}|'"${DATA_ROOT}"'|g' $DATA_ROOT/templates/*
sed -i 's|{{cert-owner-email}}|'"${CERT_OWNER_EMAIL}"'|g' $DATA_ROOT/templates/*
sed -i 's|{{portainer-fqdn}}|'"${PORTAINER_FQDN}"'|g; s|{{registry-fqdn}}|'"${REGISTRY_FQDN}"'|g; s|{{registry-ui-fqdn}}|'"${REGISTRY_UI_FQDN}"'|g' $DATA_ROOT/templates/*
sed -i 's|{{portus-secret-key-base}}|'"${PORTUS_SECRET_KEY_BASE}"'|g; s|{{portus-password}}|'"${PORTUS_PASSWORD}"'|g' $DATA_ROOT/templates/*

# Storing processed files
cp $DATA_ROOT/templates/docker-compose_nginx.yml $DATA_ROOT/compose/nginx/docker-compose.yml
cp $DATA_ROOT/templates/docker-compose_registry.yml $DATA_ROOT/compose/registry/docker-compose.yml
cp $DATA_ROOT/templates/registry.yml $DATA_ROOT/registry/config.yml
cp $DATA_ROOT/templates/portus.yml $DATA_ROOT/portus/config-local.yml
rm -rf $DATA_ROOT/templates

# Storing nginx template
cp nginx.tmpl $DATA_ROOT/nginx/templates/nginx.tmpl

# Generating internal ssl certificate
if [[ "$OSTYPE" == "msys" ]]; then
    SUBJECT='//CN='"${REGISTRY_UI_FQDN}"
elif [[ "$OSTYPE" == "win32" ]]; then
    SUBJECT='//CN='"${REGISTRY_UI_FQDN}"
else
    SUBJECT='/CN='"${REGISTRY_UI_FQDN}"
fi

openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout  $DATA_ROOT/certs/$REGISTRY_UI_FQDN.key -out $DATA_ROOT/certs/$REGISTRY_UI_FQDN.crt -days 3650 -subj $SUBJECT

# Creating nginx proxy network
docker network create --driver=bridge $NGINX_PROXY_NETWORK

echo 'Success!!!'