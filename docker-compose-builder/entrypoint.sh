#!/bin/sh

set -e

# Check if Github's user is provide as environment variable
if [ -z ${GITHUB_USER+x} ]; then
    echo "Please provide your github username as GITHUB_USER environment variable"
    echo "docker run -e GITHUB_USER=foo ..."
    exit 1
fi

# Read docker secret to get Github Oauth token
if [ ! -f /run/secrets/GITHUB_OAUTH_TOKEN ]; then
    echo "Please provide your github oauth token as a docker secret with GITHUB_OAUTH_TOKEN as secret name"
    echo "Run: echo '<Your_token>' | docker secret create GITHUB_OAUTH_TOKEN -"
    exit 1
fi

# Read docker secret to get Gpg key
if [ ! -f /run/secrets/GPG_KEY ]; then
    echo "Please provide your gpg key as a docker secret with GITHUB_OAUTH_TOKEN as secret name"
    echo "Run: echo '<Your_token>' | docker secret create GPG_KEY -"
    exit 1
fi

# Repository 
REPOSITORY_NAME="alpine-docker-compose-builder"

# Create release description
read -r -d '' RELEASE_DATA << EOM
{
  "tag_name": "${COMPOSE_VERSION}",
  "target_commitish": "master",
  "name": "v${COMPOSE_VERSION}",
  "body": "Docker compose ${COMPOSE_VERSION} Alpine compatible binary",
  "draft": false,
  "prerelease": false
}
EOM

# Sign docker-compose binary
gpg --armor --detach-sign /src/dist/docker-compose

# Publish a release on github
# Following https://developer.github.com/v3/repos/releases/#create-a-release

curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" \
     -d ${RELEASE_DATA} -X POST  https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/releases
