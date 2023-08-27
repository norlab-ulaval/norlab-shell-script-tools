#!/bin/bash
#
# Execute bats unit test in a docker container with bats-core support including several helper libraries
#
# Usage:
#   $ cd my_project_root
#   $ bash ./tests/execute_bats_tests.bash
#

TESTS_DIRECTORY=${1:-'tests'}

export BUILDKIT_PROGRESS=plain

DOCKER_FLAG="--interactive --tty --rm"
if [[ ${TEAMCITY_VERSION} ]] ; then
  DOCKER_FLAG="--tty --rm"
fi

PROJECT_GIT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_GIT_NAME=$(basename "${PROJECT_GIT_ROOT}")
REPO_ROOT=$(pwd)

if [[ "$(basename "$REPO_ROOT")" != "${PROJECT_GIT_NAME}" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] "$0" must be executed from the project root!"
  echo '(press any key to exit)'
  read -n 1
  exit 1
fi

# shellcheck disable=SC2086
docker run ${DOCKER_FLAG} --volume "$REPO_ROOT:/code" bats/bats:latest "$TESTS_DIRECTORY"
