FROM resin/resin-base:1acfee1

EXPOSE 80

RUN apt-get -q update \
	&& apt-get install -y \
		libevent-dev \
		liblzma-dev \
		libssl-dev \
		nginx \
		python-dev \
		python-gevent \
		python-pip \
		redis-server \
		swig \
	&& rm -rf /var/lib/apt/lists/* \
	&& sed --in-place 's/# maxmemory <bytes>/maxmemory 100mb/' /etc/redis/redis.conf \
	&& sed --in-place 's/# maxmemory-policy volatile-lru/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf

ENV REGISTRY_VERSION 0.9.1
ENV REGISTRY_URL https://github.com/docker/docker-registry/archive/${REGISTRY_VERSION}.tar.gz
RUN mkdir /usr/src/docker-registry \
	&& curl -s -L $REGISTRY_URL | tar xz -C /usr/src/docker-registry --strip-components=1 \
	&& ln -s /usr/src/docker-registry/config/boto.cfg /etc/boto.cfg

# Install core
RUN pip install /usr/src/docker-registry/depends/docker-registry-core

# Install registry
RUN pip install file:///usr/src/docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

RUN rm /etc/nginx/sites-enabled/default \
	&& ln -s /usr/src/app/nginx.conf /etc/nginx/sites-enabled/docker_registry \
	&& ln -s /usr/src/app/docker-registry.yml /etc/docker-registry.yml

RUN patch \
	$(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
	< /usr/src/docker-registry/contrib/boto_header_patch.diff

COPY . /usr/src/app

COPY config/services/ /etc/systemd/system/

RUN systemctl enable resin-registry.service
