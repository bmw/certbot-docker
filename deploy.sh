#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

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
    git commit -a -m "Release version $CERTBOT_VERSION"
    git tag "$BRANCH_NAME"
    git push
    git push "$BRANCH_NAME"
popd
