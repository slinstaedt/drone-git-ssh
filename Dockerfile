FROM dronee/plugin-base

RUN apk add --no-cache git git-lfs openssh-client
COPY *.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
