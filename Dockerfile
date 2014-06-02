FROM registry:0.7.0

MAINTAINER Praneeth Bodduluri "lifeeth@resin.io"

RUN apt-get install -y nginx && rm /etc/nginx/sites-enabled/default

ADD ./registry/nginx.conf /etc/nginx/sites-enabled/docker_registry

ADD ./registry/entry.sh /entry.sh

EXPOSE 80

ENTRYPOINT ["/entry.sh"]

CMD exec docker-registry
