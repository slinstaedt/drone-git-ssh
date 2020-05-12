FROM kamalook/drone-plugin-base

RUN apk add --no-cache git git-lfs openssh-client
COPY git-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "git-entrypoint.sh" ]
