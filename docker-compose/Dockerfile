FROM alpine:3.5

LABEL maintainer="big0rn0" \
      compose_version="1.11.2"

RUN wget https://github.com/big0rn0/alpine-docker-compose-builder/releases/download/${compose_version}/docker-compose \
-O /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

ENV PATH=$PATH:/usr/local/bin

ENTRYPOINT [ "/usr/local/bin/docker-compose" ]

CMD [ "--version" ]