#!/bin/bash
# =================================================================================================
# Execute 'norlab-build-system' repo shell script tests via 'norlab-shell-script-tools' library
#
# Usage:
#   $ bash run_bats_core_test_in_ns2t.bash ['<test-directory>[/<this-bats-test-file.bats>]' ['<image-distro>']]
#
# Arguments:
#   - ['<test-directory>']     The directory from which to start test, default to 'tests'
#   - ['<test-directory>/<this-bats-test-file.bats>']  A specific bats file to run, default will
#                                                      run all bats file in the test directory
#
# Globals: 
#   none
# =================================================================================================

# ToDo: refactor > use NS2T_PATH set somewhere
#NS2T_PATH="<path/to/submodule/norlab-shell-script-tools>"
bash "${NS2T_PATH:-"./utilities/norlab-shell-script-tools"}/tests/bats_testing_tools/run_bats_tests_in_docker.bash" "$@"
