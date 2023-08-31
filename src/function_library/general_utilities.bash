#!/bin/bash
#
# General purpose function library
#
# Requirement: This script must be sourced from directory 'function_library'
#
# Usage:
#   $ cd <path/to/project>/norlab-shell-script-tools/src/function_library
#   $ source ./general_utilities.bash
#

# ....Pre-condition................................................................................................
if [[ "$(basename "$(pwd)")" != "function_library" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'general_utilities.bash' script must be sourced from the 'function_library/'!\n Curent working directory is '$(pwd)'"
  echo '(press any key to exit)'
  read -nr 1
  exit 1
fi


# ....Project root logic...........................................................................................
TMP_CWD=$(pwd)

# ....Load environment variables from file.........................................................................
set -o allexport
source ../../.env.norlab_2st
source ../../.env.project
source .env.msg_style
set +o allexport

# ....Load helper function.........................................................................................
source ./prompt_utilities.bash

