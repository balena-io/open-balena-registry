FROM resin/resin-base:v4.4.1

EXPOSE 80

RUN apt-get update \
	&& apt-get install \
		musl \
	&& rm -rf /var/lib/apt/lists/*

# registry 2.6.2
ENV REGISTRY_VERSION bc5d4f15a7e8d12ed6e5174ac4edab4b6032d09f
ENV REGISTRY_SHA256 84b718193f07885b39a73be34994d50a6259f62abfca6dbd2ced279fefcc24e5

RUN URL="https://github.com/docker/distribution-library-image/blob/${REGISTRY_VERSION}/registry/registry?raw=true" \
	&& wget -qO /usr/local/bin/docker-registry "$URL" \
	&& chmod a+x /usr/local/bin/docker-registry \
	&& echo "${REGISTRY_SHA256}" /usr/local/bin/docker-registry | sha256sum -c -

COPY config/services/resin-registry.service /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable resin-registry.service
