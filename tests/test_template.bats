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
  load "bats_testing_tools/bats_helper_functions"
  #load "${BATS_HELPER_PATH}/bats-detik/load" # << Kubernetes support
else
  echo -e "\n[\033[1;31mERROR\033[0m] $0 path to bats-core helper library unreachable at \"${BATS_HELPER_PATH}\"!"
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ====Setup========================================================================================

#TODO: setup the following variable
TESTED_FILE="general_utilities.bash" 
TESTED_FILE_PATH="src/function_library"

setup_file() {
  BATS_DOCKER_WORKDIR=$(pwd) && export BATS_DOCKER_WORKDIR

  ## Uncomment the following for debug, the ">&3" is for printing bats msg to stdin
#  pwd >&3 && tree -L 1 -a -hug >&3
#  printenv >&3
}

setup() {
  cd "$TESTED_FILE_PATH" || exit 
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
  skip "Template file: Comment this line to run this test"

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
  skip "Template file: Comment this line to run this test"

  cd "${BATS_DOCKER_WORKDIR}/${TESTED_FILE_PATH}"
  run bash -c "source ./$TESTED_FILE"
  assert_success
}

@test "test me like a boss" {
  echo "TODO: write some test"
}

#@test 'fail()' {
#  fail 'this test always fails'
#}

