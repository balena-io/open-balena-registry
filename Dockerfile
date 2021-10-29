
FROM golang:1.17 AS registry
WORKDIR /src
ARG REGISTRY_VERSION=main
RUN apt-get update && apt-get install patch && rm -rf /var/lib/apt/lists/*
RUN --mount=type=bind,src=./0001-wip-balena-middleware-patch.patch,dst=/balena.patch,ro \
    wget -q -O- https://github.com/distribution/distribution/archive/${REGISTRY_VERSION}.tar.gz \
      | tar xzf - --strip-components=1 \
    && grep -v '^diff\|^index' /balena.patch | patch -p1 \
    && make bin/registry

FROM balena/open-balena-base:v12.2.0

EXPOSE 80

RUN apt-get update \
	&& apt-get install \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=registry /src/bin/registry /usr/local/bin/docker-registry

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
