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

# registry 2.5.0
ENV REGISTRY_VERSION 3688baf676da41deb7073e197e9c6348397b397d
ENV REGISTRY_SHA256 2ac1862468ab34683b6c93d1c3841b9261b9493261dcb004d28c000eddca7bbb

RUN URL="https://github.com/docker/distribution-library-image/blob/${REGISTRY_VERSION}/registry/registry?raw=true" \
	&& wget -qO /usr/local/bin/docker-registry "$URL" \
	&& chmod a+x /usr/local/bin/docker-registry \
	&& echo "${REGISTRY_SHA256}" /usr/local/bin/docker-registry | sha256sum -c -

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable resin-registry.service
