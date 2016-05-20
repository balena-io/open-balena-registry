FROM resin/resin-base:2

EXPOSE 80

ENV NGINX_VERSION 1.10.0-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install \
		apache2-utils \
		ca-certificates \
		librados2 \
		nginx=${NGINX_VERSION} \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm /etc/nginx/conf.d/default.conf \
	&& ln -s /usr/src/app/nginx.conf /etc/nginx/conf.d/docker_registry.conf

ENV REGISTRY_VERSION 2.4.1
ENV REGISTRY_BINARY_COMMIT 5cbbc8d1e6046cef5938e3380fd2a5fbd854f921
ENV REGISTRY_BINARY_URL https://github.com/docker/distribution-library-image/raw/${REGISTRY_BINARY_COMMIT}/registry/registry

RUN wget -O /usr/local/bin/docker-registry ${REGISTRY_BINARY_URL} \
	&& chmod a+x /usr/local/bin/docker-registry

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable resin-registry.service
