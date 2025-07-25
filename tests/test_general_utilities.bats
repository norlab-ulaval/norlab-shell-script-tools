#!/usr/bin/env bats
#
# Usage in docker container
#   $ REPO_ROOT=$(pwd) && RUN_TESTS_IN_DIR='tests'
#   $ docker run -it --rm -v "$REPO_ROOT:/code" bats/bats:latest "$RUN_TESTS_IN_DIR"
#
#   Note: "/code" is the working directory in the bats official image
#
# bats-core ref:
#   - https://bats-core.readthedocs.io/en/stable/tutorial.html
#   - https://bats-core.readthedocs.io/en/stable/writing-tests.html
#   - https://opensource.com/article/19/2/testing-bash-bats
#       ↳ https://github.com/dmlond/how_to_bats/blob/master/test/build.bats
#
# Helper library: 
#   - https://github.com/bats-core/bats-assert
#   - https://github.com/bats-core/bats-support
#   - https://github.com/bats-core/bats-file
#

BATS_HELPER_PATH=/usr/lib/bats
if [[ -d ${BATS_HELPER_PATH} ]]; then
  load "${BATS_HELPER_PATH}/bats-support/load"
  load "${BATS_HELPER_PATH}/bats-assert/load"
  load "${BATS_HELPER_PATH}/bats-file/load"
  load "${SRC_CODE_PATH}/${N2ST_BATS_TESTING_TOOLS_RELATIVE_PATH}/bats_helper_functions"
  #load "${BATS_HELPER_PATH}/bats-detik/load" # << Kubernetes support
else
  echo -e "\n[\033[1;31mERROR\033[0m] $0 path to bats-core helper library unreachable at \"${BATS_HELPER_PATH}\"!" 1>&2
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ====Setup========================================================================================
TESTED_FILE="general_utilities.bash"
TESTED_FILE_PATH="src/function_library"

setup_file() {
  BATS_DOCKER_WORKDIR=$(pwd) && export BATS_DOCKER_WORKDIR
#  pwd >&3 && tree -L 1 -a -hug >&3
#  printenv >&3
}

setup() {
  source .env.project
  cd $TESTED_FILE_PATH || exit 1
  source ./$TESTED_FILE
}

# ====Teardown=====================================================================================

teardown() {
  bats_print_run_env_variable_on_error
}

#teardown_file() {
#    echo "executed once after finishing the last test"
#}

# ====Test casses==================================================================================

@test "sourcing $TESTED_FILE from bad cwd › expect fail" {
  cd "${BATS_DOCKER_WORKDIR}/src/"
  # Note:
  #  - "echo 'Y'" is for sending an keyboard input to the 'read' command which expect a single character
  #    run bash -c "echo 'Y' | source ./function_library/$TESTED_FILE"
  #  - Alt: Use the 'yes [n]' command which optionaly send n time
  run bash -c "yes 1 | source ./function_library/$TESTED_FILE"
  assert_failure 1
  assert_output --partial "'$TESTED_FILE' script must be sourced from"
}

@test "sourcing $TESTED_FILE from ok cwd › expect pass" {
  cd "${BATS_DOCKER_WORKDIR}/${TESTED_FILE_PATH}"
  run bash -c "PROJECT_GIT_NAME=$PROJECT_GIT_NAME && source ./$TESTED_FILE"
  assert_success
}

@test "n2st::seek_and_modify_string_in_file ok" {
  local TMP_TEST_FILE="${cwdTEST_TEMP_DIR}/.env.tmp_test_file"
  local UNCHANGED_STR="TEST_PATH_1=/do/not/change/me/"
  local LOOKUP_STR="TEST_PATH_2="
  local ORIGINAL_STR="${LOOKUP_STR}/I/am/test/path/two"
  local MODIFIED_STR="${LOOKUP_STR}/I/am/test/path/alt"
  touch "$TMP_TEST_FILE"

  (
      echo
      echo "${UNCHANGED_STR}"
      echo "${ORIGINAL_STR}"
      echo
    ) >> "$TMP_TEST_FILE"

  run n2st::seek_and_modify_string_in_file "${LOOKUP_STR}.*" "${MODIFIED_STR}" "$TMP_TEST_FILE"
  assert_success

  assert_file_exist "${TMP_TEST_FILE}"

  run n2st::preview_file_in_promt "$TMP_TEST_FILE"
  assert_output --partial "${UNCHANGED_STR}"
  refute_output --partial "${ORIGINAL_STR}"
  assert_output --partial "${MODIFIED_STR}"
}


# ....n2st::[set_]which_python3_version ok...........................................................
@test "n2st::which_python3_version ok" {
  function python3() {
    # Mock python3 command for outputing python3 version
    echo "3.10"
  }
  export -f python3

  unset PYTHON3_VERSION

  run n2st::which_python3_version
  assert_success
  assert_output "3.10"

  unset PYTHON3_VERSION

  n2st::which_python3_version
  assert_empty "$PYTHON3_VERSION"
}

@test "n2st::set_which_python3_version ok" {
  function python3() {
    # Mock python3 command for outputing python3 version
    echo "3.10"
  }
  export -f python3

  unset PYTHON3_VERSION

  run n2st::set_which_python3_version
  assert_success
  assert_output ""

  unset PYTHON3_VERSION

  n2st::set_which_python3_version
  assert_not_empty "$PYTHON3_VERSION"
  assert_equal "$PYTHON3_VERSION" "3.10"
}

# ....n2st::[set_]which_architecture_and_os..........................................................

@test "n2st::set_which_architecture_and_os › darwin/arm64 case ok" {
  function uname() {
    # Mock uname command for darwin/arm64 case
    case "$1" in
    "-m")
      echo "arm64"
      return
      ;;
    *)
      echo "Darwin"
      return
      ;;
    esac
  }
  export -f uname

  unset IMAGE_ARCH_AND_OS
  run n2st::which_architecture_and_os
  assert_success
  assert_output "darwin/arm64"

  run n2st::set_which_architecture_and_os
  assert_success
  assert_output ""

  unset IMAGE_ARCH_AND_OS
  n2st::set_which_architecture_and_os
  assert_not_empty "$IMAGE_ARCH_AND_OS"
  assert_equal "$IMAGE_ARCH_AND_OS" "darwin/arm64"
}

@test "n2st::set_which_architecture_and_os › linux/x86 case ok" {
  function uname() {
    # Mock uname command for linux/x86_64 case
    case "$1" in
    "-m")
      echo "x86_64"
      return
      ;;
    *)
      echo "Linux"
      return
      ;;
    esac
  }
  export -f uname

  unset IMAGE_ARCH_AND_OS
  run n2st::which_architecture_and_os
  assert_success
  assert_output "linux/x86"

  run n2st::set_which_architecture_and_os
  assert_success
  assert_output ""

  unset IMAGE_ARCH_AND_OS
  n2st::set_which_architecture_and_os
  assert_not_empty "$IMAGE_ARCH_AND_OS"
  assert_equal "$IMAGE_ARCH_AND_OS" "linux/x86"
}

@test "n2st::set_which_architecture_and_os › linux/arm64 case ok" {
  function uname() {
    # Mock uname command for linux/arm64 case
    case "$1" in
    "-m")
      echo "aarch64"
      return
      ;;
    *)
      echo "Linux"
      return
      ;;
    esac
  }
  export -f uname

  unset IMAGE_ARCH_AND_OS
  run n2st::which_architecture_and_os
  assert_success
  assert_output "linux/arm64"

  run n2st::set_which_architecture_and_os
  assert_success
  assert_output ""

  unset IMAGE_ARCH_AND_OS
  n2st::set_which_architecture_and_os
  assert_not_empty "$IMAGE_ARCH_AND_OS"
  assert_equal "$IMAGE_ARCH_AND_OS" "linux/arm64"
}

@test "n2st::set_which_architecture_and_os › Jetson case ok" {
  function uname() {
    # Mock uname command for Jetson case
    case "$1" in
    "-m")
      echo "aarch64"
      return
      ;;
    "-r")
      echo "tegra"
      return
      ;;
    esac
  }
  export -f uname

  unset IMAGE_ARCH_AND_OS
  run n2st::which_architecture_and_os
  assert_success
  assert_output "l4t/arm64"

  run n2st::set_which_architecture_and_os
  assert_success
  assert_output ""

  unset IMAGE_ARCH_AND_OS
  n2st::set_which_architecture_and_os
  assert_not_empty "$IMAGE_ARCH_AND_OS"
  assert_equal "$IMAGE_ARCH_AND_OS" "l4t/arm64"
}

@test "n2st::set_which_architecture_and_os › Unsuported OS/aarch64 case expect failure" {
  function uname() {
    # Mock uname command for Unsuported OS/aarch64 case
    case "$1" in
    "-m")
      echo "aarch64"
      return
      ;;
    *)
      echo "Window"
      return
      ;;
    esac
  }
  export -f uname

  run n2st::which_architecture_and_os
  assert_failure
  assert_output --partial "Unsupported OS for aarch64 processor"
}

@test "n2st::set_which_architecture_and_os › Unsuported ARCH case expect failure" {
  function uname() {
    # Mock uname command for Unsuported ARCH case
    case "$1" in
    "-m")
      echo "unsuported_aarch"
      return
      ;;
    *)
      echo "Window"
      return
      ;;
    esac
  }
  export -f uname

  run n2st::which_architecture_and_os
  assert_failure
  assert_output --partial "Unsupported processor architecture"
}

# ====legacy API support testing===================================================================
@test "(legacy API support testing) seek_and_modify_string_in_file ok" {
  local TMP_TEST_FILE="${cwdTEST_TEMP_DIR}/.env.tmp_test_file"
  local UNCHANGED_STR="TEST_PATH_1=/do/not/change/me/"
  local LOOKUP_STR="TEST_PATH_2="
  local ORIGINAL_STR="${LOOKUP_STR}/I/am/test/path/two"
  local MODIFIED_STR="${LOOKUP_STR}/I/am/test/path/alt"
  touch "$TMP_TEST_FILE"

  (
      echo
      echo "${UNCHANGED_STR}"
      echo "${ORIGINAL_STR}"
      echo
    ) >> "$TMP_TEST_FILE"

  run seek_and_modify_string_in_file "${LOOKUP_STR}.*" "${MODIFIED_STR}" "$TMP_TEST_FILE"
  assert_success
  run n2st::preview_file_in_promt "$TMP_TEST_FILE"
  assert_output --partial "${UNCHANGED_STR}"
  refute_output --partial "${ORIGINAL_STR}"
  assert_output --partial "${MODIFIED_STR}"
}

@test "(legacy API support testing) set_which_python3_version ok" {
  run set_which_python3_version
  assert_success

  set_which_python3_version
  assert_not_empty "$PYTHON3_VERSION"
  # assert_equal "$PYTHON3_VERSION" "3.10" # Note: the container base image is "ubuntu:lates" -> the python verison will change
}

@test "(legacy API support testing) set_which_architecture_and_os ok" {
  run set_which_architecture_and_os
  assert_success

  set_which_architecture_and_os
  assert_not_empty "$IMAGE_ARCH_AND_OS"
}
