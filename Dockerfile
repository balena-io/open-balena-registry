FROM registry:0.7.0

# Suppresses "debconf: unable to initialize frontend: Dialog" errors
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update

RUN apt-get install -y nginx && rm /etc/nginx/sites-enabled/default

ADD ./nginx.conf /etc/nginx/sites-enabled/docker_registry

ADD ./entry.sh /entry.sh

EXPOSE 80

ENTRYPOINT ["/entry.sh"]

CMD exec docker-registry
