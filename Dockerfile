FROM balena/open-balena-base:v11.1.0

EXPOSE 80

RUN apt-get update \
	&& apt-get install \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

# registry 2.7.1
ENV REGISTRY_VERSION 0b6ea3ba50b65563600a717f07db4cfa6f18f957
ENV REGISTRY_SHA256 d494c104bc9aa4b39dd473f086dbe0a5bdf370f1cb4a7b9bb2bd38b5e58bb106

RUN URL="https://github.com/docker/distribution-library-image/raw/${REGISTRY_VERSION}/amd64/registry" \
	&& wget -qO /usr/local/bin/docker-registry "$URL" \
	&& chmod a+x /usr/local/bin/docker-registry \
	&& echo "${REGISTRY_SHA256}" /usr/local/bin/docker-registry | sha256sum -c -

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
