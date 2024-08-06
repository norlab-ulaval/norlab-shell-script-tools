#!/bin/bash
# =================================================================================================
# Execute bats unit test in a docker container with bats-core support including several helper libraries
#
# Usage:
#   $ cd my_project_root
#   $ bash ./tests/run_bats_tests_in_docker.bash ['<test-directory>[/<this-bats-test-file.bats>]' ['<image-distro>']]
#
# Arguments:
#   - ['<test-directory>']     The directory from which to start test, default to 'tests'
#   - ['<test-directory>/<this-bats-test-file.bats>']  A specific bats file to run, default will
#                                                      run all bats file in the test directory
#   - ['<image-distro>']          ubuntu or alpine (default ubuntu)
#
# =================================================================================================

RUN_TESTS_IN_DIR=${1:-'tests'}
BATS_DOCKERFILE_DISTRO=${2:-'ubuntu'}

# ....Option.......................................................................................
## Set Docker builder log output for debug. Options: plain, tty or auto (default)
#export BUILDKIT_PROGRESS=plain

# ....N2ST root logic..............................................................................
REPO_ROOT=$(pwd)
N2ST_BATS_TESTING_TOOLS_ABS_PATH="$( cd "$( dirname "${0}" )" &> /dev/null && pwd )"

# ToDo: assessment › harccoding the relative path is more robust. Since the location wont change anymore, the version with string substitution is irelevant.
N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH=".${N2ST_BATS_TESTING_TOOLS_ABS_PATH/$REPO_ROOT/}"
#N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH="tests/bats_testing_tools"

#N2ST_PATH=$( git rev-parse --show-toplevel )
N2ST_PATH="${N2ST_BATS_TESTING_TOOLS_ABS_PATH}/../.."
test -d "${N2ST_PATH}" || exit 1
#tree -a -L 1 ${N2ST_PATH}


# ....Source project shell-scripts dependencies....................................................
pushd "$(pwd)" >/dev/null || exit 1
source "${N2ST_PATH}"/import_norlab_shell_script_tools_lib.bash || exit 1
popd >/dev/null || exit 1

# ....Project root logic...........................................................................
PROJECT_CLONE_GIT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_CLONE_GIT_NAME=$(basename "$PROJECT_CLONE_GIT_ROOT" .git)
PROJECT_GIT_REMOTE_URL=$(git remote get-url origin)
PROJECT_GIT_NAME=$(basename "${PROJECT_GIT_REMOTE_URL}" .git)

# ....Pre-condition................................................................................
if [[ $(basename "$REPO_ROOT") != ${PROJECT_CLONE_GIT_NAME} ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] $0 must be executed from the project root!\nCurrent wordir: $(pwd)" 1>&2
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

test -d "${N2ST_BATS_TESTING_TOOLS_ABS_PATH}" || exit 1
test -f "${N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH}/bats_helper_functions.bash" ||  exit 1

# ====Begin========================================================================================
n2st::set_is_teamcity_run_environment_variable
if [[ ${IS_TEAMCITY_RUN} != true ]] && [[ -z ${BUILDX_BUILDER} ]]; then
  n2st::norlab_splash "${PROJECT_PROMPT_NAME}" "${PROJECT_GIT_REMOTE_URL}"
fi
n2st::print_formated_script_header "$(basename $0) ${MSG_END_FORMAT}on device ${MSG_DIMMED_FORMAT}$(hostname -s)" "${MSG_LINE_CHAR_BUILDER_LVL2}"

n2st::print_msg "IS_TEAMCITY_RUN=${IS_TEAMCITY_RUN} ${TC_VERSION}"
if [[ -z ${BUILDX_BUILDER} ]]; then
  # Note: Default to default buildx builder (ie native host architecture) so that the build img
  # be available in the local image store and that tests executed via docker run doesn't
  # require pulling built img from dockerhub.
  n2st::set_which_architecture_and_os
  n2st::print_msg "Current image architecture and os: $IMAGE_ARCH_AND_OS"
  if [[ $IMAGE_ARCH_AND_OS == 'darwin/arm64' ]]; then
    export BUILDX_BUILDER=desktop-linux
  else
    export BUILDX_BUILDER=default
  fi
  n2st::print_msg "Setting BUILDX_BUILDER=$BUILDX_BUILDER"
  # Force builder initialisation
  docker buildx inspect --bootstrap $BUILDX_BUILDER >/dev/null
fi

# ....Execute docker steps.........................................................................
# Note:
#   - CONTAINER_PROJECT_ROOT_NAME is for copying the source code including the repository root (i.e.: the project name)
#   - BUILDKIT_CONTEXT_KEEP_GIT_DIR is for setting buildkit to keep the .git directory in the container
#     Source https://docs.docker.com/build/building/context/#keep-git-directory

# Do not load MSG_BASE nor MSG_BASE_TEAMCITY from there .env file so that tested logic does not leak in that file
_MSG_BASE="\033[1m[${PROJECT_GIT_NAME}]\033[0m"
_MSG_BASE_TEAMCITY="|[${PROJECT_GIT_NAME}|]"

if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockOpened name='${_MSG_BASE_TEAMCITY} Build custom bats-core docker image']"
else
  echo -e "\n\n${_MSG_BASE} Building custom bats-core ${BATS_DOCKERFILE_DISTRO} docker image\n"
fi

docker build \
  --build-arg "CONTAINER_PROJECT_ROOT_NAME=${PROJECT_GIT_NAME}" \
  --build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1 \
  --build-arg N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH="$N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH" \
  --build-arg "TEAMCITY_VERSION=${TEAMCITY_VERSION}" \
  --build-arg "N2ST_VERSION=${N2ST_VERSION:?err}" \
  --file "${N2ST_BATS_TESTING_TOOLS_ABS_PATH}/Dockerfile.bats-core-code-isolation.${BATS_DOCKERFILE_DISTRO}" \
  --tag n2st-bats-test-code-isolation/"${PROJECT_GIT_NAME}" \
  "${REPO_ROOT}"

# done: NMO-571 fix: unable to find image faillure on build server › Cause: image were build using docker-container builder because of the --platform flag
# (NICE TO HAVE) ToDo: assessment >> Not sure its relevant to have multiarch build logic since test are executed at runtime not build time.
#  --platform "linux/$(uname -m)" \
#  --load \

if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockClosed name='${_MSG_BASE_TEAMCITY} Build custom bats-core docker image']"
fi


if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockOpened name='${_MSG_BASE_TEAMCITY} Run bats-core tests']"
else
  echo -e "\n\n${_MSG_BASE} Starting bats-core test run on ${BATS_DOCKERFILE_DISTRO}\n"
fi

if [[ ${TEAMCITY_VERSION} ]]; then
  # The '--interactive' flag is not compatible with TeamCity build agent
  docker run --tty --rm n2st-bats-test-code-isolation/"${PROJECT_GIT_NAME}" "$RUN_TESTS_IN_DIR"
else
  docker run --interactive --tty --rm n2st-bats-test-code-isolation/"${PROJECT_GIT_NAME}" "$RUN_TESTS_IN_DIR"
fi
DOCKER_EXIT_CODE=$?

if [[ ${TEAMCITY_VERSION} ]] && [[ $DOCKER_EXIT_CODE != 0 ]]; then
  # Fail the build › Will appear on the TeamCity Build Results page
  echo -e "##teamcity[buildProblem description='BUILD FAIL with docker exit code: ${DOCKER_EXIT_CODE}']"
fi

if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockClosed name='${_MSG_BASE_TEAMCITY} Run bats-core tests']"
fi

# ====Teardown=====================================================================================
exit $DOCKER_EXIT_CODE
