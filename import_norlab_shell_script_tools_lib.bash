#!/bin/bash
#
# Import norlab-shell-script-tools function library and dependencies
#
# Usage:
#   $ cd <path/to/norlab-shell-script-tools/root>
#   $ PROJECT_PROMPT_NAME=MySuperProject
#   $ source import_norlab_shell_script_tools_lib.bash
#
#   alternate way
#
#   $ cd <my/superproject/root>
#   $ set -o allexport && source ./utilities/norlab-shell-script-tools/.env.project && set +o allexport
#   $ cd ./utilities/norlab-shell-script-tools
#   $ source import_norlab_shell_script_tools_lib.bash
#
#

MSG_DIMMED_FORMAT="\033[1;2m"
MSG_ERROR_FORMAT="\033[1;31m"
MSG_END_FORMAT="\033[0m"

function n2st::source_lib(){
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ====Begin======================================================================================
#  N2ST_PATH=$(git rev-parse --show-toplevel)
  _PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]:-'.'}")"
  N2ST_PATH="$(dirname "${_PATH_TO_SCRIPT}")"


  cd "${N2ST_PATH}/src/function_library" || exit
  for each_file in "$(pwd)"/*.bash ; do
      source "${each_file}"
  done

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
#  cd "${N2ST_ROOT_DIR}/src/utility_scripts"
#  PATH=$PATH:${N2ST_ROOT_DIR}/src/utility_scripts

  # ====Teardown===================================================================================
  cd "${TMP_CWD}"
}


if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  echo "${MSG_ERROR_FORMAT}[ERROR]${MSG_END_FORMAT} This script must be sourced from an other script"
else
  # This script is being sourced, ie: __name__="__source__"
  n2st::source_lib
fi

