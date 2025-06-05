#!/bin/bash
# =================================================================================================
# Execute '<my-superproject>' repository .bats shell script tests using 'norlab-shell-script-tools'
# library. Under the hood, it will copy or optionaly mount the repository source code in a docker
# container and execute every .bats tests located in the '<test-directory>'. The script can be
# executed from anywhere as long as its inside the '<my-superproject>' repository.
#
# Initial setup
#   1. ToDo: Copy this script somewhere in your superproject. Recommend the `tests` directory.
#   2. ToDo: Write some .bats tests. See 'tests/tests_template/test_template.bats' for inspiration.
#   3. (optional) ToDo: set N2ST_PATH="<path/to/submodule/norlab-shell-script-tools>"
#   4. Execute the script and let the magic hapen
#
# Usage:
#  $ bash run_bats_core_test_in_n2st.bash [--mount-src-code-as-a-volume] [--help]
#                                         ['<test-directory>[/<bats-test-file-name.bats>]' ['<image-distro>']]
#
# Arguments:
#   --mount-src-code-as-a-volume      Mount the source code at run time instead of copying it at build time.
#                                     Comromise in isolation to the benefit of increase velocity.
#                                     Usefull for project dealing with large files but require
#                                     handling temporary files and directory manualy via bats-file.
#   -h | --help                       Show the N2ST script run_bats_tests_in_docker.bash help message
#
# Positional argument:
#   '<test-directory>'                The directory from which to start test (default to 'tests')
#   '<bats-test-file-name.bats>'      A specific bats file to run, default will run all bats file
#                                      in the test directory
#   '<image-distro>'                  ubuntu or alpine (default ubuntu)
#
# Globals:
#   Read N2ST_PATH    Default to "./utilities/norlab-shell-script-tools"
#
# =================================================================================================
params=( "$@" )

set -e            # exit on error
set -o nounset    # exit on unbound variable
set -o pipefail   # exit if errors within pipes

if [[ -z ${params} ]]; then
  # Set to default bats tests directory if none specified
  params="tests/"
fi

function n2st::teardown() {
  EXIT_CODE=$?
  cd "${SUPERPROJECT_PATH:?err}" || exit 1
  # Add any teardown logic here
  exit ${EXIT_CODE:1}
}
trap n2st::teardown EXIT

# ....Project root logic.........................................................................
SUPERPROJECT_PATH=$(git rev-parse --show-toplevel)
N2ST_PATH=${N2ST_PATH:-"./utilities/norlab-shell-script-tools"}

# ....Execute N2ST run_bats_tests_in_docker.bash.................................................
cd "$SUPERPROJECT_PATH"

bash "${N2ST_PATH:?err}/tests/bats_testing_tools/run_bats_tests_in_docker.bash" "${params[@]}"

# ....Teardown.....................................................................................
# Handle by the trap command

