FROM bigorn0/pyinstaller:alpine-3.5

ARG COMPOSE_VERSION=1.11.2

ENV COMPOSE_VERSION=${COMPOSE_VERSION}

RUN echo "Building docker-compose version ${COMPOSE_VERSION} Alpine compatible binary."

RUN apk add --no-cache curl ca-certificates gnupg && \
    git clone --branch ${COMPOSE_VERSION} https://github.com/docker/compose.git /src && \
    # pyinstaller needs Git sha to build from docker-compose.spec
    git rev-parse --short HEAD > /src/compose/GITSHA

# Build docker-compose
RUN /pyinstaller/pyinstaller.sh --noconfirm --onefile --log-level DEBUG --clean docker-compose.spec

WORKDIR /src/dist/

# Test docker-compose
RUN set -e && ./docker-compose --version

#COPY ./entrypoint.sh /entrypoint.sh

# https://developer.github.com/v3/repos/releases/#create-a-release
ENTRYPOINT [ "echo", "docker-compose", "is built in /src/dist/" ]