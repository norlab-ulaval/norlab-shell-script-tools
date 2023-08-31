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

RUN_TESTS_IN_DIR=${1:-'tests'}

# ....Option.......................................................................................................
## Set Docker builder log output for debug. Options: plain, tty or auto (default)
#export BUILDKIT_PROGRESS=plain

# ====Begin========================================================================================================
# ....Project root logic...........................................................................................
PROJECT_GIT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_GIT_NAME=$(basename "${PROJECT_GIT_ROOT}")
REPO_ROOT=$(pwd)

if [[ $(basename "$REPO_ROOT") != "$PROJECT_GIT_NAME" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] $0 must be executed from the project root!"
  echo '(press any key to exit)'
  read -n 1
  exit 1
fi


# ....Execute docker steps..........................................................................................
docker build \
  --build-arg "PROJECT_ROOT=$(basename "${PROJECT_GIT_ROOT}")" \
  --file ./tests/bats_testing_tools/Dockerfile.bats-core-code-isolation \
  --tag bats/bats-core-code-isolation \
  .

#clear
echo -e "\n\n:: Starting bats-core test run :::::::::::::::::::::::::::::::::::::::::::::::\n"

if [[ ${TEAMCITY_VERSION} ]] ; then
  # The '--interactive' flag is not compatible with TeamCity build agent
  docker run --tty --rm bats/bats-core-code-isolation "$RUN_TESTS_IN_DIR"
else
  docker run --interactive --tty --rm bats/bats-core-code-isolation "$RUN_TESTS_IN_DIR"
fi

# ====Teardown=====================================================================================================
