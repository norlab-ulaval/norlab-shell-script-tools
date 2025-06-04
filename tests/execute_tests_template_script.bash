#!/bin/bash

clear
export N2ST_PATH=./
bash tests/tests_template/run_bats_core_test_in_n2st.bash tests
exit $?
