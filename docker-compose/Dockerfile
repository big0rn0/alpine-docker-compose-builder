FROM alpine:3.5

LABEL maintainer="big0rn0"

COPY ./docker-compose /usr/local/bin

ENV PATH=$PATH:/usr/local/bin

ENTRYPOINT [ "/usr/local/bin/docker-compose" ]

CMD [ "--version" ]