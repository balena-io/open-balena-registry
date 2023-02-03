FROM balena/open-balena-base:v14.4.0

EXPOSE 80

RUN apt-get update \
	&& apt-get install \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

ENV REGISTRY_VERSION 2.8.1
ENV REGISTRY_SHA256 f1a376964912a5fd7d588107ebe5185da77803244e15476d483c945959347ee2

RUN curl -SLO "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" && \
	echo "${REGISTRY_SHA256} registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" | sha256sum -c - && \
	tar xz -f "registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" && \
	mv registry /usr/local/bin/docker-registry && \
	rm "registry_${REGISTRY_VERSION}_linux_amd64.tar.gz"

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
