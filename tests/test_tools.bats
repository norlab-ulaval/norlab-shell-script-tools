#!/usr/bin/env bats
#
# Usage in docker container
#   $ REPO_ROOT=$(pwd) && TESTS_DIRECTORY='tests'
#   $ docker run -it --rm -v "$REPO_ROOT:/code" bats/bats:latest "$TESTS_DIRECTORY"
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
  #load "${BATS_HELPER_PATH}/bats-detik/load" # << Kubernetes support
else
  echo -e "\n[\033[1;31mERROR\033[0m] $0 path to bats-core helper library unreachable at \"${BATS_HELPER_PATH}\"!"
  echo '(press any key to exit)'
  read -n 1
  exit 1
fi

# ====Setup========================================================================================================

#setup_file() {
#   echo "executed once befor starting the first test"
#  pwd && ls && exit
#}

#setup() {
#    echo "executed before each test"
#}

# ====Teardown=====================================================================================================

#teardown() {
#    echo "executed after each test"
#}

#teardown_file() {
#    echo "executed once after finishing the last test"
#}

# ====Test casses==================================================================================================
# Livetemplate shortcut: @test

@test "test me like a boss › auto merge 7" {
    echo "test release"
}

#@test 'fail()' {
#  fail 'this test always fails'
#}


# ////scratch//////////////////////////////////////////////////////////////////////////////////////////////////////
#On release PR to main › run test + publish status
#tests/run_bats_tests_in_docker.bash

#refs/heads/dev
#NorLab-TeamCity-server auto merge | Updated the dev branch with the latest release (see PR %teamcity.pullRequest.number%)
