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
BRANCH_NAME="${1:-main}"
BRANCH_NAME_SLUG=$(slugify "$BRANCH_NAME")
STACK="$REPO_NAME-$BRANCH_NAME_SLUG"

export BRANCH_NAME_SLUG


echo "******** ENV **********"
echo "WORKING_DIR: $SCRIPT_DIR"
echo "REPO_NAME: $REPO_NAME"
echo "BRANCH_NAME: $BRANCH_NAME"
echo "STACK: $STACK"
echo "***********************"


echo "$PWD"
test ! -f "$SCRIPT_DIR/.env.$BRANCH_NAME_SLUG" && {
    cp ".env.example" ".env.$BRANCH_NAME_SLUG"

    echo "Remember to set up the .env file"
}

# set up stack deploy command
DEPLOY_COMMAND=(docker stack deploy --with-registry-auth)
FILES=()

# use base compose file if existing
file="$SCRIPT_DIR/docker-compose.yml"
test -f "$file" && {
    FILES+=(-f "$file")
    DEPLOY_COMMAND+=(-c "$file")
}

file="$SCRIPT_DIR/docker-compose.$BRANCH_NAME_SLUG.yml"

# use the example file if missing the branch file
test -f "$file" || {
  cp "$SCRIPT_DIR/docker-compose.override.yml.example" "$file"
}

# append branch compose file if existing
test -f "$file" && {
    FILES+=(-f "$file")
    DEPLOY_COMMAND+=(-c "$file")
}

# append stack name
DEPLOY_COMMAND+=("$STACK")

echo "###  Compose config"
echo "" "${FILES[@]}"
echo "###"
echo ""
echo "### Running command"
echo " >" "${DEPLOY_COMMAND[@]}"
echo "###"



"${DEPLOY_COMMAND[@]}"
