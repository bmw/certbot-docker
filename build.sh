#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script builds certbot docker and certbot dns plugins docker against a given release version of certbot.
# The build is done following the environment used by Dockerhub to handle its autobuild feature, and so can be
# used as a pre-deployment validation test.

# Usage: ./build.sh [VERSION]
#   with [VERSION] corresponding to a released version of certbot, like `v0.34.0`

trap Cleanup 1 2 3 6

Cleanup() {
    if [ ! -z "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR/plugin/certbot" || true
        rm -rf "$WORK_DIR/core/certbot" || true
    fi
    popd 2> /dev/null || true
}

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

DOCKER_TAG="$1"
SOURCE_BRANCH="$DOCKER_TAG"
 
StandardHubBuild() {
    local L_IMAGE_NAME="$1"
    local L_CONTEXT_PATH="$2"
    local L_DOCKERFILE_RELATIVE_PATH="$3"
    local L_DOCKERFILE_PATH="$L_CONTEXT_PATH/$L_DOCKERFILE_RELATIVE_PATH"
    docker build -f "$L_DOCKERFILE_PATH" -t "$L_IMAGE_NAME" "$L_CONTEXT_PATH"
}

Cleanup

# Step 1: Certbot core Docker

DOCKER_REPO="certbot/certbot"
CONTEXT_PATH="$WORK_DIR/core"
DOCKERFILE_RELATIVE_PATH="Dockerfile"
IMAGE_NAME="$DOCKER_REPO:$DOCKER_TAG"

pushd "$CONTEXT_PATH"
    SOURCE_BRANCH="$SOURCE_BRANCH" bash hooks/pre_build
    StandardHubBuild "$IMAGE_NAME" "$(pwd)" "$DOCKERFILE_RELATIVE_PATH"
popd

Cleanup

# Step 2: Certbot dns plugins Dockers

CERTBOT_PLUGINS_DOCKER_REPOS=(
    "certbot/dns-dnsmadeeasy"
    "certbot/dns-dnsimple"
    "certbot/dns-ovh"
    "certbot/dns-cloudflare"
    "certbot/dns-cloudxns"
    "certbot/dns-digitalocean"
    "certbot/dns-google"
    "certbot/dns-luadns"
    "certbot/dns-nsone"
    "certbot/dns-rfc2136"
    "certbot/dns-route53"
    "certbot/dns-gehirn"
    "certbot/dns-linode"
    "certbot/dns-sakuracloud"
)

for DOCKER_REPO in ${CERTBOT_PLUGINS_DOCKER_REPOS[@]}; do
    CONTEXT_PATH="$WORK_DIR/plugin"
    DOCKERFILE_RELATIVE_PATH="Dockerfile"
    IMAGE_NAME="$DOCKER_REPO:$DOCKER_TAG"

    pushd "$CONTEXT_PATH"
        SOURCE_BRANCH="$SOURCE_BRANCH" DOCKER_TAG="$DOCKER_TAG" bash hooks/pre_build
        SOURCE_BRANCH="$SOURCE_BRANCH" DOCKER_TAG="$DOCKER_TAG" DOCKER_REPO="$DOCKER_REPO" bash hooks/build
    popd

    Cleanup
done
