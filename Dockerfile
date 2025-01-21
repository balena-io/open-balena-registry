FROM balena/open-balena-base:18.0.24-no-systemd

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

COPY . /usr/src/app

# The ENTRYPOINT inherited from open-balena-base:no-systemd is "/usr/bin/confd-entry.sh"
# so we need to pass our own entrypoint as the CMD
CMD [ "/usr/src/app/entry.sh" ]
