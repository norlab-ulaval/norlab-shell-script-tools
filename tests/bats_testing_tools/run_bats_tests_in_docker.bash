#!/bin/bash
DOCUMENTATION_RUN_BATS_TESTS_IN_DOCKER=$( cat <<'EOF'
# =================================================================================================
# Execute bats unit test in a docker container with bats-core support including several helper
# libraries. Under the hood, it will copy or optionaly mount the repository source code in a docker
# container and execute every .bats tests located in the '<test-directory>'.
#
# Usage:
#   $ cd path/to/my/project/root
#   $ bash ./tests/run_bats_tests_in_docker.bash [--mount-src-code-as-a-volume] [--help]
#                                                ['<test-directory>[/<bats-test-file-name.bats>]' ['<image-distro>']]
#
# Arguments:
#   --mount-src-code-as-a-volume      Mount the source code at run time instead of copying it at build time.
#                                     Comromise in isolation to the benefit of increase velocity.
#                                     Usefull for project dealing with large files but require
#                                     handling temporary files and directory manualy via bats-file.
#   -h | --help                       Show this help message
#
# Positional argument:
#   '<test-directory>'                The directory from which to start test (default to 'tests')
#   '<bats-test-file-name.bats>'      A specific bats file to run, default will run all bats file
#                                      in the test directory
#   '<image-distro>'                  ubuntu or alpine (default ubuntu)
#
# =================================================================================================
EOF
)
# ....Option.......................................................................................
## Set Docker builder log output for debug. Options: plain, tty or auto (default)
#export BUILDKIT_PROGRESS=plain

# ....N2ST root logic..............................................................................
REPO_ROOT=$(pwd)
N2ST_BATS_TESTING_TOOLS_ABS_PATH="$( cd "$( dirname "${0}" )" &> /dev/null && pwd )"
N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH=".${N2ST_BATS_TESTING_TOOLS_ABS_PATH/$REPO_ROOT/}"

N2ST_PATH="${N2ST_BATS_TESTING_TOOLS_ABS_PATH}/../.."
test -d "${N2ST_PATH}" || exit 1

# ....Source project shell-scripts dependencies....................................................
cd "${N2ST_PATH}" || exit 1
source import_norlab_shell_script_tools_lib.bash || exit 1
cd "${REPO_ROOT}" || exit 1

# ....Set env variables (pre cli)................................................................
declare -a REMAINING_ARGS
declare MOUNT_SRC_CODE_AS_A_VOLUME=false

# ....cli..........................................................................................
function show_help() {
  # (NICE TO HAVE) ToDo: refactor as a n2st fct (ref NMO-583)
  echo -e "${MSG_DIMMED_FORMAT}"
  n2st::draw_horizontal_line_across_the_terminal_window "="
  echo -e "$0 --help\n"
  # Strip shell comment char `#` and both lines
  echo -e "${DOCUMENTATION_RUN_BATS_TESTS_IN_DOCKER}" | sed 's/\# ====.*//' | sed 's/^\#//'
  n2st::draw_horizontal_line_across_the_terminal_window "="
  echo -e "${MSG_END_FORMAT}"
}

while [ $# -gt 0 ]; do

  case $1 in
    --mount-src-code-as-a-volume)
      MOUNT_SRC_CODE_AS_A_VOLUME=true
      shift # Remove argument (--mount-src-code-as-a-volume)
      ;;
    -h | --help)
      clear
      show_help
      exit
      ;;
    --) # no more option
      shift
      REMAINING_ARGS=( "$@" )
      break
      ;;
    *) # Default case
      REMAINING_ARGS=("$@")
      break
      ;;
  esac

done

# ....Set env variables (post cli)...............................................................
RUN_TESTS_IN_DIR=${REMAINING_ARGS[0]:-'tests'}
BATS_DOCKERFILE_DISTRO=${REMAINING_ARGS[1]:-'ubuntu'}


# ....Project root logic...........................................................................
SUPER_PROJECT_GIT_ROOT=$(git rev-parse --show-toplevel)
SUPER_PROJECT_GIT_ROOT_NAME=$(basename "$SUPER_PROJECT_GIT_ROOT" .git)
PROJECT_GIT_REMOTE_URL=$(git remote get-url origin)
PROJECT_GIT_NAME=$(basename "${PROJECT_GIT_REMOTE_URL}" .git)
CONTAINER_TAG=$(echo "n2st-bats-test-code-isolation/${PROJECT_GIT_NAME}" | tr '[:upper:]' '[:lower:]' )

# ....Pre-condition................................................................................
if [[ "$(basename "${REPO_ROOT}")" != "${SUPER_PROJECT_GIT_ROOT_NAME}" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] $0 must be executed from the project root!\nCurrent wordir: $(pwd)\n
REPO_ROOT: ${REPO_ROOT}\nSUPER_PROJECT_GIT_ROOT_NAME: ${SUPER_PROJECT_GIT_ROOT_NAME}" 1>&2
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

test -d "${N2ST_BATS_TESTING_TOOLS_ABS_PATH}" || exit 1
test -f "${N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH}/bats_helper_functions.bash" ||  exit 1

# ====Begin========================================================================================
n2st::set_is_teamcity_run_environment_variable
n2st::norlab_splash "${PROJECT_PROMPT_NAME}" "${PROJECT_GIT_REMOTE_URL}"
n2st::print_formated_script_header "$(basename $0) ${MSG_END_FORMAT}on device ${MSG_DIMMED_FORMAT}$(hostname -s)" "${MSG_LINE_CHAR_BUILDER_LVL2}"

n2st::print_msg "IS_TEAMCITY_RUN=${IS_TEAMCITY_RUN} ${TC_VERSION}"
if [[ -z ${BUILDX_BUILDER} ]]; then
  # Note: Default to default buildx builder (ie native host architecture) so that the build img
  # be available in the local image store and that tests executed via docker run doesn't
  # require pulling built img from dockerhub.
  n2st::set_which_architecture_and_os
  n2st::print_msg "Current image architecture and os: $IMAGE_ARCH_AND_OS"
  if [[ $IMAGE_ARCH_AND_OS == 'darwin/arm64' ]]; then
    # Note: Do nothing since the new macOs docker context/builder behavior produce error when
    # setting BUILDX_BUILDER to desktop-linux/default. See issue NMO-742 for details.
    :
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

BUILD_FLAG=()
BUILD_FLAG+=(--build-arg "CONTAINER_PROJECT_ROOT_NAME=${PROJECT_GIT_NAME}")
BUILD_FLAG+=(--build-arg BUILDKIT_CONTEXT_KEEP_GIT_DIR=1)
BUILD_FLAG+=(--build-arg N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH="$N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH")
BUILD_FLAG+=(--build-arg "TEAMCITY_VERSION=${TEAMCITY_VERSION}")
BUILD_FLAG+=(--build-arg "N2ST_VERSION=${N2ST_VERSION:?err}")
BUILD_FLAG+=(--file "${N2ST_BATS_TESTING_TOOLS_ABS_PATH}/Dockerfile.bats-core-code-isolation.${BATS_DOCKERFILE_DISTRO}")
if [[ ${MOUNT_SRC_CODE_AS_A_VOLUME} == true ]]; then
  BUILD_FLAG+=(--target mount-version)
  CONTAINER_TAG="${CONTAINER_TAG}-mount"
  CONTEXT="${N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH}"
else
  BUILD_FLAG+=(--target copy-version)
  CONTEXT="${REPO_ROOT}"
fi

n2st::print_msg "Execute ${MSG_DIMMED_FORMAT}docker build ${BUILD_FLAG[*]} --tag ${CONTAINER_TAG} ${CONTEXT}${MSG_END_FORMAT}\n"
docker build "${BUILD_FLAG[@]}" --tag "${CONTAINER_TAG}" "${CONTEXT}" || exit 1

if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockClosed name='${_MSG_BASE_TEAMCITY} Build custom bats-core docker image']"
fi

if [[ ${TEAMCITY_VERSION} ]]; then
  echo -e "##teamcity[blockOpened name='${_MSG_BASE_TEAMCITY} Run bats-core tests']"
else
  echo -e "\n\n${_MSG_BASE} Starting bats-core test run on ${BATS_DOCKERFILE_DISTRO}\n"
fi

RUN_ARG=(--tty --rm)
RUN_ARG+=(--env "TERM=${TERM:-xterm-256color}")
if [[  ${IS_TEAMCITY_RUN} == false ]]; then
  # The '--interactive' flag is not compatible with TeamCity build agent
  RUN_ARG+=(--interactive)
fi
if [[ ${MOUNT_SRC_CODE_AS_A_VOLUME} == true ]]; then
  RUN_ARG+=(--privileged)
  RUN_ARG+=(--volume "${SUPER_PROJECT_GIT_ROOT}":/code/"${PROJECT_GIT_NAME}")
fi

n2st::print_msg "Execute ${MSG_DIMMED_FORMAT}docker run ${RUN_ARG[*]} ${CONTAINER_TAG} $RUN_TESTS_IN_DIR${MSG_END_FORMAT}\n"
docker run "${RUN_ARG[@]}" "${CONTAINER_TAG}" "$RUN_TESTS_IN_DIR"
DOCKER_EXIT_CODE=$?

if [[ ${IS_TEAMCITY_RUN} == true ]] && [[ $DOCKER_EXIT_CODE != 0 ]]; then
  # Fail the build › Will appear on the TeamCity Build Results page
  echo -e "##teamcity[buildProblem description='BUILD FAIL with docker exit code: ${DOCKER_EXIT_CODE}']"
fi

if [[ ${IS_TEAMCITY_RUN} == true ]]; then
  echo -e "##teamcity[blockClosed name='${_MSG_BASE_TEAMCITY} Run bats-core tests']"
fi

# ====Teardown=====================================================================================
exit $DOCKER_EXIT_CODE
