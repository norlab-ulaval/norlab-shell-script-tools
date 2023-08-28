#!/bin/bash
#
# Execute bats unit test in a docker container with bats-core support including several helper libraries
#
# Usage:
#   $ cd my_project_root
#   $ bash ./tests/run_bats_tests_in_docker.bash ['<test-directory>']
#
# Arguments:
#   ['<test-directory>']  The directory from which to start test, default to 'tests'
#

TESTS_DIRECTORY=${1:-'tests'}

# ....Option.......................................................................................................
## Set Docker builder log output for debug
#export BUILDKIT_PROGRESS=plain

# ====Begin========================================================================================================
# ....Project root logic...........................................................................................
PROJECT_GIT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_GIT_NAME=$(basename "${PROJECT_GIT_ROOT}")
REPO_ROOT=$(pwd)

if [[ "$(basename "$REPO_ROOT")" != "${PROJECT_GIT_NAME}" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] $0 must be executed from the project root!"
  echo '(press any key to exit)'
  read -n 1
  exit 1
fi

DOCKER_FLAG="--tty --rm"
if [[ ! ${TEAMCITY_VERSION} ]] ; then
  # The '--interactive' flag is not compatible with TeamCity build agent
  DOCKER_FLAG="--interactive ${DOCKER_FLAG}"
fi

# ....Execute docker steps..........................................................................................
docker build --file ./tests/Dockerfile.bats-core-code-isolation --tag bats/bats-core-code-isolation .

# shellcheck disable=SC2086
docker run ${DOCKER_FLAG} bats/bats-core-code-isolation "$TESTS_DIRECTORY"

# ====Teardown=====================================================================================================

