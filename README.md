# alpine-docker-compose-builder
Builder for workable single Alpine compatible docker compose binary.
Pet repository to use `--squash` build option.
I wanted to avoid the need to install python and pip to get a minimal `docker-compose` image based on Alpine.
I gathered informations from open issue on [docker/compose](https://github.com/docker/compose/issues/3465).
Gathers some different pieces I found reading Docker issues comments.

# Requirements to build docker images:
* Docker 1.13+ because the build uses `--squash`



# Disclaimer: 
This work is heavily inspired and based on
* tjamet's [tjamet/docker-compose](https://github.com/tjamet/docker-compose/blob/master/Dockerfile)
* six8's [six8/pyinstaller-alpine](https://github.com/six8/pyinstaller-alpine)
I wasn't able to make them them work directly from alpine 3.5 so I rebuilt all steps.

Thanks!

# Download binary
```
TODO
```

# Use docker-compose image
* Docker Hub: ...

```
---
version: "3.1"
services:
  web:
    image: nginx:latest
    ports:
      - 80:80

docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}/docker-compose.yml:/test/docker-compose.yml:ro bigorn0/docker-compose -f /test/docker-compose.yml up
```
