#!/bin/sh
set -euo pipefail

function isenv {
	env | grep -q "^$1="
}

isenv DRONE_WORKSPACE && cd $DRONE_WORKSPACE
isenv DRONE_COMMIT_AUTHOR_NAME || export DRONE_COMMIT_AUTHOR_NAME=drone
isenv DRONE_COMMIT_AUTHOR_EMAIL || export DRONE_COMMIT_AUTHOR_EMAIL=drone@localhost
export GIT_AUTHOR_NAME=${DRONE_COMMIT_AUTHOR_NAME}
export GIT_AUTHOR_EMAIL=${DRONE_COMMIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${DRONE_COMMIT_AUTHOR_NAME}
export GIT_COMMITTER_EMAIL=${DRONE_COMMIT_AUTHOR_EMAIL}

if isenv DRONE_NETRC_MACHINE; then
	echo "Git credentials: /root/.netrc"
	cat <<EOF > /root/.netrc
machine ${DRONE_NETRC_MACHINE}
login ${DRONE_NETRC_USERNAME:-}
password ${DRONE_NETRC_PASSWORD:-}
EOF
fi

_ssh="$HOME/.ssh"
test -e $_ssh || mkdir $_ssh && chmod 700 $_ssh
if isenv PLUGIN_SSH_KEY; then
	printf "$PLUGIN_SSH_KEY" > $_ssh/id_rsa
	chmod 600 $_ssh/id_rsa
	echo "Git key: $_ssh/id_rsa"
fi
if isenv PLUGIN_HOST_KEY; then
	printf "$PLUGIN_HOST_KEY" > $_ssh/known_hosts
	echo "Host key: $_ssh/known_hosts"
fi
printf "Host *\n$(env2args pascal '  $k $v\n' PLUGIN_SSH_CONFIG_)" > $_ssh/config
echo "Git config: $_ssh/config" && cat $_ssh/config && echo
