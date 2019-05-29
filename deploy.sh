#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script deploys a new version of certbot dockers (core+plugins) regarding a released version of Certbot.
# The README.md is updated to include the reference of this new version, and a tag version is pushed to the
# Certbot Docker repository, triggering the DockerHub autobuild feature that will take care of the release.

# Usage: ./deploy.sh [VERSION]
#   with [VERSION] corresponding to a released version of certbot, like `v0.34.0`

trap Cleanup 1 2 3 6

Cleanup() {
    popd 2> /dev/null || true
}

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

CERTBOT_VERSION="$1"
BRANCH_NAME=$(sed -E -e 's|v(.*)\.[0-9]+|\1.x|g' <<< $CERTBOT_VERSION)

sed -i -e "s|current-.*-blue\.svg|current-$CERTBOT_VERSION-blue.svg|g" README.md
sed -i -e "s|branch=.*)\]|branch=$BRANCH_NAME)]|g" README.md

pushd "$WORK_DIR"
    git commit -a -m "Release version $CERTBOT_VERSION" --allow-empty
    git tag "$CERTBOT_VERSION"
    git push
    git push --tags
popd
