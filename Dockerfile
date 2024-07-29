FROM balena/open-balena-base:v18.0.8

# hadolint ignore=DL3008
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		musl \
	&& rm -rf /var/lib/apt/lists/*

ENV REGISTRY_VERSION 2.8.3
ENV REGISTRY_SHA256_amd64 b1f750ecbe09f38e2143e22c61a25e3da2afe1510d9522859230b480e642ceff
ENV REGISTRY_SHA256_arm64 7d2252eeeac97dd60fb9b36bebd15b95d7f947c4c82b8e0824cb55233ece9cd0

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
