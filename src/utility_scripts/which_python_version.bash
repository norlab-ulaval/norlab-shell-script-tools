#!/bin/bash
#
# Utility script to check the current python version and set PYTHON3_VERSION environment variable
#
# Requirement: This script must be sourced from directory 'utility_scripts'
#
# Usage:
#   $ cd <path/to/project>/norlab-shell-script-tools/src/utility_scripts
#   $ source ./which_python_version.bash
#
# Globals:
#   write 'PYTHON3_VERSION'
#

# ....Pre-condition................................................................................................
if [[ "$(basename "$(pwd)")" != "utility_scripts" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'which_python_version.bash' script must be sourced from the 'utility_scripts/'!\n Curent working directory is '$(pwd)'"
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ....Load helper function.........................................................................................
TMP_CWD=$(pwd)

set -o allexport
source ../../.env.norlab_2st
set +o allexport

cd ../function_library || exit
source ./general_utilities.bash

cd "${TMP_CWD}"

# ====Begin========================================================================================================
set_which_python3_version

