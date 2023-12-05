#!/bin/bash

function n2st::source_lib(){
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ====Begin======================================================================================
  N2ST_PATH_TO_SRC_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
  N2ST_ROOT_DIR="$(dirname "${N2ST_PATH_TO_SRC_SCRIPT}")"

  cd "${N2ST_ROOT_DIR}/src/function_library"
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
#  cd "${N2ST_ROOT_DIR}/src/utility_scripts"
#  PATH=$PATH:${N2ST_ROOT_DIR}/src/utility_scripts

  # ====Teardown===================================================================================
  cd "${TMP_CWD}"
}

n2st::source_lib
