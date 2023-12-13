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
  echo -e "\n[\033[1;31mERROR\033[0m] $0 path to bats-core helper library unreachable at \"${BATS_HELPER_PATH}\"!"
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ====Setup========================================================================================

TESTED_FILE="import_norlab_shell_script_tools_lib.bash"
TESTED_FILE_PATH="./"

# executed once before starting the first test (valide for all test in that file)
setup_file() {
  BATS_DOCKER_WORKDIR=$(pwd) && export BATS_DOCKER_WORKDIR

  ## Uncomment the following for debug, the ">&3" is for printing bats msg to stdin
#  pwd >&3 && tree -L 1 -a -hug >&3
#  printenv >&3
}

# executed before each test
setup() {
  source .env.project
  assert_not_empty "$PROJECT_GIT_NAME"
  cd "$TESTED_FILE_PATH" || exit
}

# ====Teardown=====================================================================================

# executed after each test
teardown() {
  bats_print_run_env_variable_on_error
}

## executed once after finishing the last test (valide for all test in that file)
#teardown_file() {
#}

# ====Test casses==================================================================================

@test "source all script in 'src/function_library' directory (set environment variable check) › expect pass" {
  assert_empty "${MSG_PROMPT_NAME}"
  assert_not_empty "$PROJECT_GIT_NAME"

  run bash -c "PROJECT_PROMPT_NAME=MyCoolTester && source $TESTED_FILE && printenv"
  assert_success
  assert_output --partial "MSG_PROMPT_NAME=MyCoolTester"
}

@test "validate env var are not set between test run" {
  assert_empty "${MSG_PROMPT_NAME}"
  assert_empty "${PROJECT_PROMPT_NAME}"
#  assert_empty "${NBS_PATH}"
#  assert_empty "${NBS_TMP_TEST_LIB_SOURCING_ENV_EXPORT}"
}

@test "source all script in 'src/function_library' directory (import function check) › expect pass" {
  source "$TESTED_FILE"
  export GREETING="Hello NorLab"

  run n2st::good_morning_norlab
  assert_success
  assert_output --partial "${GREETING} ... there's nothing like the smell of a snow storm in the morning!"

  run n2st::norlab_splash
  assert_success

#  run n2st::set_which_architecture_and_os >&3
  run n2st::set_which_architecture_and_os
  assert_success
}

@test "run \"bash $TESTED_FILE\" › expect fail" {
  run bash "$TESTED_FILE"
  assert_success
  assert_output --partial "This script must be sourced from an other script"
}

