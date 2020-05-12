#!/bin/sh
set -euo pipefail

source git-env-setup.sh

function isenv {
	env | grep -q "^$1="
}

isenv PLUGIN_GIT_INIT_CMD && $PLUGIN_GIT_INIT_CMD

_url="${PLUGIN_GIT_URL:-$DRONE_GIT_SSH_URL}"
if [ -e .git ]; then
	git remote set-url origin $_url
else
	git clone $(env2args kebab '--$k $v' PLUGIN_CLONE_) $_url $PWD
	if isenv PLUGIN_GIT_REF || isenv DRONE_COMMIT_REF; then
		set -x
		case "${PLUGIN_GIT_REF:-$DRONE_COMMIT_REF}" in
			refs/heads/* )
				git checkout ${PLUGIN_GIT_BRANCH:-$DRONE_COMMIT_BRANCH}
				;;
			refs/tags/* )
				git checkout ${PLUGIN_GIT_REF:-$DRONE_COMMIT_REF}
				;;
			refs/pull/* | refs/pull-request/* | refs/pull-requests/* | refs/merge-requests/* )
				git checkout ${DRONE_TARGET_BRANCH}
				git fetch origin ${DRONE_COMMIT_REF}
				git merge FETCH_HEAD
				;;
			*)
				git checkout ${PLUGIN_GIT_COMMIT_SHA:-$DRONE_COMMIT_SHA}
				;;
		esac
		set +x
	fi
fi

isenv PLUGIN_GIT_CMD && $PLUGIN_GIT_CMD
exit 0
