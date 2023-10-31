FROM balena/open-balena-base:v16.0.11

EXPOSE 80
EXPOSE 81

# hadolint ignore=DL3008
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

ENV REGISTRY_VERSION 2.8.2
ENV REGISTRY_SHA256_amd64 b68ffb849bcdb49639dc91ba97baba6618346f95fedc0fcc94871b31d515d205
ENV REGISTRY_SHA256_arm64 3d500cf4f7f21ade4bdfef28012aef8e1ec2b221d2d8d36d201d94dda84fa727

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
