FROM balena/open-balena-base:v14.7.3

EXPOSE 80
EXPOSE 81

# hadolint ignore=DL3008
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

ENV REGISTRY_VERSION 2.8.1
ENV REGISTRY_SHA256_amd64 f1a376964912a5fd7d588107ebe5185da77803244e15476d483c945959347ee2
ENV REGISTRY_SHA256_arm64 4c588c8e62c9a84f1eecfba4c842fe363b91be87fd42e3b5dac45148a2f46c52

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN asset="registry_${REGISTRY_VERSION}_linux_$(dpkg --print-architecture).tar.gz" && \
	sha256="REGISTRY_SHA256_$(dpkg --print-architecture)" && \
	curl -fsSL -O "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/${asset}" && \
	echo "${!sha256} ${asset}" | sha256sum -c - && \
	tar xz -f "${asset}" && \
	mv registry /usr/local/bin/docker-registry && \
	rm "${asset}"

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
