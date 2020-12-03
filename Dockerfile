FROM balena/open-balena-base:no-systemd-master

EXPOSE 80

# registry 2.7.1
ARG REGISTRY_VERSION=0b6ea3ba50b65563600a717f07db4cfa6f18f957
ARG REGISTRY_SHA256=d494c104bc9aa4b39dd473f086dbe0a5bdf370f1cb4a7b9bb2bd38b5e58bb106

RUN URL="https://github.com/docker/distribution-library-image/raw/${REGISTRY_VERSION}/amd64/registry" \
	&& wget -qO /usr/local/bin/docker-registry "$URL" \
	&& chmod a+x /usr/local/bin/docker-registry \
	&& echo "${REGISTRY_SHA256}" /usr/local/bin/docker-registry | sha256sum -c -

COPY . /usr/src/app
CMD [ "/usr/src/app/entry.sh" ]
