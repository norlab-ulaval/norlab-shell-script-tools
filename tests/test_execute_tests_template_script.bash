#!/bin/bash
# =================================================================================================
# This is an integration test to validate the template test script
#
# Usage:
#   $ bash test_execute_tests_template_script.bash
#
# =================================================================================================
clear
export N2ST_PATH=./
bash tests/tests_template/run_bats_core_test_in_n2st.bash tests
exit $?
