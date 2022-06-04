#!/bin/bash
#
if [[ -z "$1" ]]; then
    echo "USAGE: ./deploy.sh <branch_name>"
    exit 1;
fi

slugify () {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR" || exit 1

REPO_NAME=${PWD##*/}
BRANCH_NAME=$(slugify "${1:-main}")
STACK="$REPO_NAME-$BRANCH_NAME"

echo "******** ENV **********"
echo "WORKING_DIR: $SCRIPT_DIR"
echo "REPO_NAME: $REPO_NAME"
echo "STACK: $STACK"
echo "***********************"


echo "$PWD"
test ! -f "$SCRIPT_DIR/.env" && {
    cp .env.example .env

    echo "Remember to set up the .env file"

}

# set up stack deploy command
DEPLOY_COMMAND=(docker stack deploy --with-registry-auth)

# append compose file if existing
file="$SCRIPT_DIR/docker-compose.yml"
test -f "$file" && {
    DEPLOY_COMMAND+=(-c "$file")
}

# append override file if existing
file="$SCRIPT_DIR/docker-compose.override.yml"
test -f "$file" && {
    DEPLOY_COMMAND+=(-c "$file")
}

# append stack name
DEPLOY_COMMAND+=("$STACK")

echo "### Running command"
echo " >" "${DEPLOY_COMMAND[@]}"
echo "###"
"${DEPLOY_COMMAND[@]}"
