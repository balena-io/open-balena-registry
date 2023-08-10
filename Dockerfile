FROM alpine:3.18.3 AS build

RUN apk add --no-cache github-cli

ARG TARGETOS
ARG TARGETARCH

# https://github.com/distribution/distribution/actions/workflows/build.yml?query=branch%3Amain
# (e.g.) https://github.com/distribution/distribution/actions/runs/5794478637
ARG GH_RUN_ID=5794478637

RUN --mount=type=secret,id=GITHUB_TOKEN \
    GH_TOKEN=$(cat < /run/secrets/GITHUB_TOKEN) gh run download -R distribution/distribution "${GH_RUN_ID}" -n registry \
    && find . -type f -name "*_${TARGETOS}_${TARGETARCH}.tar.gz" | xargs tar -zxvf \
    && ./registry --version


FROM balena/open-balena-base:v15.0.3

EXPOSE 80
EXPOSE 81

# hadolint ignore=DL3008
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		musl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=build /registry /usr/local/bin/docker-registry

COPY config/services/ /etc/systemd/system/

COPY . /usr/src/app

RUN systemctl enable balena-registry.service
