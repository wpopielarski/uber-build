#!/bin/bash
#
# Creates tags for all repos that should be included in a Scala IDE product.
#
# Example call of this script:
#
#     ./mk-git-tags.sh config/release-41x-211-luna.conf /path/to/repos "Scala IDE 4.1.0-RC1 release"

CONFIG_FILE=$1
BASE_DIR=$2
SIGN_MESSAGE=$3 #"Scala IDE 4.1.0-RC1 release"

# Check if CONFIG_FILE is a file
[ -z "$CONFIG_FILE" ] && echo "error: no config file specified" && exit 1
[ ! -f "$CONFIG_FILE" ] && echo "error: invalid config file" && exit 1
# Check if BASE_DIR is a directory
[ -z "$BASE_DIR" ] && echo "error: no base directory specified" && exit 1
[ ! -d "$BASE_DIR" ] && echo "error: invalid base directory" && exit 1
# Check if SIGN_MESSAGE is empty
[ -z "$SIGN_MESSAGE" ] && echo "error: no message for git tag signing specified" && exit 1
# Chick that only two parameters are passed
[ -n "$4" ] && echo "error: only two parameters allowed" && exit 1

source $CONFIG_FILE

SCALA_IDE_DIR="$BASE_DIR/scala-ide"
SCALA_REFACTORING_DIR="$BASE_DIR/scala-refactoring"
WORKSHEET_PLUGIN_DIR="$BASE_DIR/scala-worksheet"
PLAY_PLUGIN_DIR="$BASE_DIR/scala-ide-play2"
SEARCH_PLUGIN_DIR="$BASE_DIR/scala-search"
PRODUCT_DIR="$BASE_DIR/scala-ide-product"

# Check if all necessary repos exist
[ ! -d "$SCALA_IDE_DIR" ] && echo "error: $SCALA_IDE_DIR does not exist" && exit 1
[ ! -d "$SCALA_REFACTORING_DIR" ] && echo "error: $SCALA_REFACTORING_DIR does not exist" && exit 1
[ ! -d "$WORKSHEET_PLUGIN_DIR" ] && echo "error: $WORKSHEET_PLUGIN_DIR does not exist" && exit 1
[ ! -d "$PLAY_PLUGIN_DIR" ] && echo "error: $PLAY_PLUGIN_DIR does not exist" && exit 1
[ ! -d "$PRODUCT_DIR" ] && echo "error: $PRODUCT_DIR does not exist" && exit 1

# Creates the tag that is specified in CONFIG_FILE or do nothing if it already exist.
#
# $1 - repo directory to move to
# $2 - git tag name
# $3 - git tag sign message
function createTag() {
  echo ""
  echo ">>> Handle repo: `basename $1`"
  cd "$1"
  # check if tag already exists
  if git rev-parse "$2" > /dev/null 2>&1; then
    echo ">>> Tag $2 already exists"
  else
    echo ">>> Create tag $2"
    git tag -s -m "$3" "$2"
    git push origin "$2"
  fi
}

echo ">>> All checks successful. Starting to create tags now."

createTag "$SCALA_IDE_DIR" "$SCALA_IDE_GIT_BRANCH" "$SIGN_MESSAGE"
createTag "$SCALA_REFACTORING_DIR" "$SCALA_REFACTORING_GIT_BRANCH" "$SIGN_MESSAGE"
createTag "$WORKSHEET_PLUGIN_DIR" "$WORKSHEET_PLUGIN_GIT_BRANCH" "$SIGN_MESSAGE"
createTag "$PLAY_PLUGIN_DIR" "$PLAY_PLUGIN_GIT_BRANCH" "$SIGN_MESSAGE"
createTag "$SEARCH_PLUGIN_DIR" "$SEARCH_PLUGIN_GIT_BRANCH" "$SIGN_MESSAGE"
createTag "$PRODUCT_DIR" "$PRODUCT_GIT_BRANCH" "$SIGN_MESSAGE"

echo ""
echo ">>> success"
