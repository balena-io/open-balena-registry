#!/bin/sh
set -e
# Use confd for generating the config
# -- The host etcd needed for confd in coreos always runs on the ports below
if nc -z -w 4 172.17.42.1 4001;
then
    /usr/local/bin/confd -verbose -onetime -node 'http://172.17.42.1:4001' -confdir=/etc/confd
    export DOCKER_REGISTRY_CONFIG=/config/config.yml
    export SETTINGS_FLAVOR=prod
fi

service nginx start

[ "$1" ] && exec "$@"
