FROM registry:0.8.0

# Suppresses "debconf: unable to initialize frontend: Dialog" errors
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update

RUN apt-get install -y nginx wget && rm /etc/nginx/sites-enabled/default

RUN wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.6.0-alpha3/confd-0.6.0-alpha3-linux-amd64 && chmod a+x /usr/local/bin/confd && mkdir -p /etc/confd/{conf.d,templates}
ADD ./config/config.toml /etc/confd/conf.d/config.toml
ADD ./config/config.tmpl /etc/confd/templates/config.tmpl
RUN mkdir /config

ADD ./nginx.conf /etc/nginx/sites-enabled/docker_registry

ADD ./entry.sh /entry.sh

EXPOSE 80 5000

ENTRYPOINT ["/entry.sh"]

CMD exec docker-registry
