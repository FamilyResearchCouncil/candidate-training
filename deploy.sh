#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BRANCH_NAME="${1:-main}"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.$BRANCH_NAME.yml"
REPO_NAME=${PWD##*/}
STACK="$REPO_NAME-$BRANCH_NAME"

echo "******** ENV **********"
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BRANCH_NAME: $BRANCH_NAME"
echo "COMPOSE_FILE: $COMPOSE_FILE"
echo "REPO_NAME: $REPO_NAME"
echo "STACK: $STACK"
echo "***********************"


echo "$PWD"
test ! -f ".env" && {
    echo "Please set up the .env file"
    exit 1
}

DEPLOY_COMMAND=(docker stack deploy --with-registry-auth)

test -f "docker-compose.yml" && {
    DEPLOY_COMMAND+=(-c docker-compose.yml)
}

test -f "docker-compose.override.yml" && {
    DEPLOY_COMMAND+=(-c docker-compose.override.yml)
}

test -f "$COMPOSE_FILE" && {
    echo "Deploying stack '$STACK' to the swarm"
    DEPLOY_COMMAND+=(-c "$COMPOSE_FILE")
}

DEPLOY_COMMAND+=("$STACK")

echo "### Running command"
echo " >" "${DEPLOY_COMMAND[@]}"
echo "###"
"${DEPLOY_COMMAND[@]}"
