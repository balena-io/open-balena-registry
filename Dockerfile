FROM balena/open-balena-base:20.0.1-no-init

ARG REGISTRY_VERSION=3.0.0
ARG REGISTRY_SHA256_amd64=61c9a2c0d5981a78482025b6b69728521fbc78506d68b223d4a2eb825de5ca3d
ARG REGISTRY_SHA256_arm64=6c2ee1d135626fa42e0d6fb66a0e0f42e22439e5050087d04f4c5ff53655892e
ENV OTEL_TRACES_EXPORTER=none

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN asset="registry_${REGISTRY_VERSION}_linux_$(dpkg --print-architecture).tar.gz" && \
	sha256="REGISTRY_SHA256_$(dpkg --print-architecture)" && \
	curl -fsSL -O "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/${asset}" && \
	echo "${!sha256} ${asset}" | sha256sum -c - && \
	tar xz -f "${asset}" && \
	mv registry /usr/local/bin/docker-registry && \
	rm "${asset}"

COPY . /usr/src/app

# The ENTRYPOINT inherited from open-balena-base:no-systemd is "/usr/bin/confd-entry.sh"
# so we need to pass our own entrypoint as the CMD
CMD [ "/usr/src/app/entry.sh" ]
