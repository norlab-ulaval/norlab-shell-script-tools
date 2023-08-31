#!/bin/bash
#
# Execute bats unit test in a docker container with bats-core support including several helper libraries
#
# Usage:
#   $ cd my_project_root
#   $ bash ./tests/run_bats_tests_in_docker.bash ['<test-directory>' ['<image-distro>']]
#
# Arguments:
#   - ['<test-directory>']  The directory from which to start test, default to 'tests'
#   - ['<image-distro>'] ubuntu or alpine (default ubuntu)
#

RUN_TESTS_IN_DIR=${1:-'tests'}
BATS_DOCKERFILE_DISTRO=${2:-'ubuntu'}

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
  read -nr 1
  exit 1
fi


# ....Execute docker steps..........................................................................................
# Note:
#   - PROJECT_ROOT is for copying the source code including the repository root (i.e.: the project name)
#   - BUILDKIT_CONTEXT_KEEP_GIT_DIR is for setting buildkit to keep the .git directory in the container
#     Source https://docs.docker.com/build/building/context/#keep-git-directory

docker build \
  --build-arg "PROJECT_ROOT=$(basename "${PROJECT_GIT_ROOT}")" \
  --build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1 \
  --file "./tests/bats_testing_tools/Dockerfile.bats-core-code-isolation.${BATS_DOCKERFILE_DISTRO}" \
  --tag bats/bats-core-code-isolation \
  .

#clear
echo -e "\n\n:: Starting bats-core test run on ${BATS_DOCKERFILE_DISTRO} ::::::::::::::::::::::::::::::\n"

if [[ ${TEAMCITY_VERSION} ]] ; then
  # The '--interactive' flag is not compatible with TeamCity build agent
  docker run --tty --rm bats/bats-core-code-isolation "$RUN_TESTS_IN_DIR"
else
  docker run --interactive --tty --rm bats/bats-core-code-isolation "$RUN_TESTS_IN_DIR"
fi

# ====Teardown=====================================================================================================
