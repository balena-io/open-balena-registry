FROM balena/open-balena-base:v13.1.0

EXPOSE 80

RUN apt-get update \
	&& apt-get install \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

ENV REGISTRY_VERSION 2.8.0
ENV REGISTRY_SHA256 7b2ebc3d67e21987b741137dc230d0f038b362ba21e02f226150ff5577f92556

RUN curl -SLO "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" && \
	echo "${REGISTRY_SHA256} registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" | sha256sum -c - && \
	tar xz -f "registry_${REGISTRY_VERSION}_linux_amd64.tar.gz" && \
	mv registry /usr/local/bin/docker-registry && \
	rm "registry_${REGISTRY_VERSION}_linux_amd64.tar.gz"

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
