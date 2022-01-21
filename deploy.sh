#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR" || exit 1

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
test ! -f "$SCRIPT_DIR/.env" && {
    echo "Please set up the .env file"
    exit 1
}

DEPLOY_COMMAND=(docker stack deploy --with-registry-auth)

file="$SCRIPT_DIR/docker-compose.yml"
test -f "$file" && {
    DEPLOY_COMMAND+=(-c "$file")
}

file="$SCRIPT_DIR/docker-compose.override.yml"
test -f "$file" && {
    DEPLOY_COMMAND+=(-c "$file")
}

file="$SCRIPT_DIR/$COMPOSE_FILE"
test -f "$file" && {
    DEPLOY_COMMAND+=(-c "$file")
}

DEPLOY_COMMAND+=("$STACK")

echo "### Running command"
echo " >" "${DEPLOY_COMMAND[@]}"
echo "###"
"${DEPLOY_COMMAND[@]}"
