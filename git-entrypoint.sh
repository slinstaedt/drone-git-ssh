#!/bin/sh
set -euo pipefail

_ssh="$HOME/.ssh"

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

test -e $_ssh || mkdir $_ssh && chmod 700 $_ssh
if isenv PLUGIN_GIT_KEY; then
	printf "$PLUGIN_GIT_KEY" > $_ssh/id_rsa
	chmod 600 $_ssh/id_rsa
	echo "Git key: $_ssh/id_rsa"
fi
if isenv PLUGIN_HOST_KEY; then
	printf "$PLUGIN_HOST_KEY" > $_ssh/known_hosts
	echo "Host key: $_ssh/known_hosts"
fi
printf "Host *\n$(env2args pascal '  $k $v\n' PLUGIN_SSH_)" > $_ssh/config
echo "Git config: $_ssh/config" && cat $_ssh/config && echo

isenv PLUGIN_GIT_INIT_CMD && $PLUGIN_GIT_INIT_CMD

_url="${PLUGIN_GIT_URL:-$DRONE_GIT_SSH_URL}"
if [ -e .git ]; then
	git remote set-url origin $_url
else
	git clone $(env2args kebab '--$k $v' PLUGIN_CLONE_) $_url .
	if isenv PLUGIN_GIT_REF || isenv DRONE_COMMIT_REF; then
		case "${PLUGIN_GIT_REF:-$DRONE_COMMIT_REF}" in
			refs/heads/* )
				git checkout ${PLUGIN_GIT_BRANCH:-$DRONE_COMMIT_BRANCH}
				;;
			refs/tags/* )
				git checkout ${PLUGIN_GIT_REF:-$DRONE_COMMIT_REF}
				;;
			refs/pull/* | refs/pull-request/* | refs/merge-requests/* )
				git checkout ${DRONE_COMMIT_BRANCH}
				git fetch origin ${DRONE_COMMIT_REF}
				git merge ${DRONE_COMMIT_SHA}
				;;
			*)
				git checkout ${PLUGIN_GIT_COMMIT_SHA:-$DRONE_COMMIT_SHA}
				;;
		esac
	fi
fi

isenv PLUGIN_GIT_CMD && $PLUGIN_GIT_CMD
exit 0
