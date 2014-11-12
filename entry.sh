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

#--- The following is needed to disable sqlalchemy
export SEARCH_BACKEND=

#--- Source environment variables

if [ -f /config/env ];
then
    source /config/env
fi

export LOGENTRIES_ACCOUNT_KEY=${LOGENTRIES_ACCOUNT_KEY:=}

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
supervisorctl start resin-registry
service nginx start

#--- Start Logentries daemon
if [ $LOGENTRIES_ACCOUNT_KEY ]; then
    #--- HOTFIX: Logentries fails to register, disable exit on error
    set +o errexit

    /usr/bin/le init --account-key=${LOGENTRIES_ACCOUNT_KEY}
    /usr/bin/le register --name=REGISTRY
    /usr/bin/le follow '/resin-log/resin_registry_stdout.log' --name=REGISTRY_LOGS_STDOUT
    /usr/bin/le follow '/resin-log/resin_registry_error.log' --name=REGISTRY_LOGS_ERROR
    /usr/bin/le follow '/var/log/nginx/access.log' --name=NGINX_LOGS_ERROR
    /usr/bin/le follow '/var/log/nginx/error.log' --name=NGINX_LOGS_ERROR
    service logentries start
fi

[ "$1" ] && exec "$@"
