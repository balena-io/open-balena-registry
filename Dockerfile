FROM resin/resin-base:v4.2.1

EXPOSE 80

ENV NGINX_VERSION 1.12.1-1~stretch

RUN wget https://sks-keyservers.net/sks-keyservers.netCA.pem -O /usr/local/share/ca-certificates/sks-keyservers.crt \
	&& update-ca-certificates \
	&& apt-key adv --keyserver hkps://hkps.pool.sks-keyservers.net --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo 'deb http://nginx.org/packages/debian/ stretch nginx' >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install \
		apache2-utils \
		ca-certificates \
		librados2 \
		nginx=${NGINX_VERSION} \
		musl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm /usr/local/share/ca-certificates/sks-keyservers.crt \
	&& update-ca-certificates \
	&& rm /etc/nginx/conf.d/default.conf \
	&& rm /etc/nginx/nginx.conf

# registry 2.6.2
ENV REGISTRY_VERSION bc5d4f15a7e8d12ed6e5174ac4edab4b6032d09f
ENV REGISTRY_SHA256 84b718193f07885b39a73be34994d50a6259f62abfca6dbd2ced279fefcc24e5

RUN URL="https://github.com/docker/distribution-library-image/blob/${REGISTRY_VERSION}/registry/registry?raw=true" \
	&& wget -qO /usr/local/bin/docker-registry "$URL" \
	&& chmod a+x /usr/local/bin/docker-registry \
	&& echo "${REGISTRY_SHA256}" /usr/local/bin/docker-registry | sha256sum -c -

# Include official nginx unit file, as else otherwise it won't start correctly.
# See: https://www.nginx.com/resources/wiki/start/topics/examples/systemd/
COPY config/services/nginx.service /lib/systemd/system/

COPY config/services/resin-registry.service /etc/systemd/system/

RUN ln -s /usr/src/app/nginx.conf /etc/nginx/nginx.conf

COPY . /usr/src/app

RUN systemctl enable resin-registry.service
