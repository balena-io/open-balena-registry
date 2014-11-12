FROM registry:0.9.0

# Suppresses "debconf: unable to initialize frontend: Dialog" errors
ENV DEBIAN_FRONTEND noninteractive

RUN echo 'deb http://rep.logentries.com/ trusty main' > /etc/apt/sources.list.d/logentries.list \
	&& gpg --keyserver pgp.mit.edu --recv-keys C43C79AD && gpg -a --export C43C79AD | apt-key add - \
	&& apt-get -q update \
	&& apt-get install -qy supervisor nginx wget logentries logentries-daemon \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* && rm /etc/nginx/sites-enabled/default

RUN wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.6.0-alpha3/confd-0.6.0-alpha3-linux-amd64 && chmod a+x /usr/local/bin/confd && mkdir -p /etc/confd/conf.d && mkdir -p /etc/confd/templates
ADD ./config/config.toml /etc/confd/conf.d/config.toml
ADD ./config/config.tmpl /etc/confd/templates/config.tmpl
ADD ./config/env.toml /etc/confd/conf.d/env.toml
ADD ./config/env.tmpl /etc/confd/templates/env.tmpl
RUN mkdir /config /resin-log

ADD ./nginx.conf /etc/nginx/sites-enabled/docker_registry
ADD resin-registry.conf /etc/supervisor/conf.d/resin-registry.conf

ADD ./entry.sh /entry.sh

EXPOSE 80 5000

ENTRYPOINT ["/entry.sh"]

CMD ["tail", "-f", "/var/log/supervisor/supervisord.log"]
