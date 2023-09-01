#!/bin/bash
#
# General purpose function library
#
# Requirement: This script must be sourced from directory 'function_library'
#
# Usage:
#   $ cd <path/to/project>/norlab-shell-script-tools/src/function_library
#   $ source ./teamcity_utilities.bash
#


# ....Pre-condition................................................................................................
if [[ "$(basename "$(pwd)")" != "function_library" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'teamcity_utilities.bash' script must be sourced from the 'function_library/'!\n Curent working directory is '$(pwd)'"
  echo '(press any key to exit)'
  read -nr 1
  exit 1
fi

# ....Load environment variables from file.........................................................................
set -o allexport
source ../../.env.norlab_2st
source ../../.env.project
source .env.msg_style
set +o allexport

# ....Load helper function.........................................................................................
source ./prompt_utilities.bash

# =================================================================================================================
# Check if the script is executed in JetBrains TeamCity continuous integration/deployment server
# and set the IS_TEAMCITY_RUN environment variable accordingly
#
# Usage:
#   $ set_is_teamcity_run_environment_variable
#
# Globals:
#   [Read]  'TEAMCITY_VERSION'
#   [write] 'IS_TEAMCITY_RUN'
# Returns:
#   none
# =================================================================================================================
function set_is_teamcity_run_environment_variable() {
  if [[ ${TEAMCITY_VERSION} ]] ; then
    IS_TEAMCITY_RUN=true && export IS_TEAMCITY_RUN
  fi
}


# =================================================================================================================
# Send TeamCity blockOpened/blockClosed service message
#   or print the message to console when executed outside a TeamCity Agent run.
#
# Usage:
#   $ teamcity_service_msg_blockOpened "<theMessage>"
#   $ ... many steps ...
#   $ teamcity_service_msg_blockClosed
#
# Globals:
#   Read        'IS_TEAMCITY_RUN'
#   Read|write  'CURRENT_BLOCK_SERVICE_MSG'
# Outputs:
#   Output either
#     - a TeamCity blockOpened/blockClosed service message
#     - or print to console
#     - or an error if teamcity_service_msg_blockOpened is not closed using teamcity_service_msg_blockClosed
#
# Reference:
#   - TeamCity doc: https://www.jetbrains.com/help/teamcity/service-messages.html#Blocks+of+Service+Messages
#
# ToDo: assessment >> consider adding the logic to check "if run in teamcity" inside this function instead of relying on the IS_TEAMCITY_RUN env variable
# =================================================================================================================
function teamcity_service_msg_blockOpened() {
  local THE_MSG=$1
  if [[ ${CURRENT_BLOCK_SERVICE_MSG} ]]; then
    print_msg_error_and_exit "The TeamCity bloc service message ${MSG_DIMMED_FORMAT}${CURRENT_BLOCK_SERVICE_MSG}${MSG_END_FORMAT} was not closed using function ${MSG_DIMMED_FORMAT}teamcity_service_msg_blockClosed${MSG_END_FORMAT}."
  else
    export CURRENT_BLOCK_SERVICE_MSG="${THE_MSG}"
  fi

  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} ${THE_MSG}']"
  else
    echo && print_msg "${THE_MSG}" && echo
  fi
}

function teamcity_service_msg_blockClosed() {
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} ${CURRENT_BLOCK_SERVICE_MSG}']"
  fi
  # Reset the variable since the bloc is closed
  unset CURRENT_BLOCK_SERVICE_MSG
}

# =================================================================================================================
# Send TeamCity compilationStarted/compilationFinished service message
#   or print the message to console when executed outside a TeamCity Agent run.
#
# Usage:
#   $ teamcity_service_msg_compilationStarted "<theMessage>"
#   $ ... many compilation steps ...
#   $ teamcity_service_msg_compilationFinished
#
# Globals:
#   Read        'IS_TEAMCITY_RUN'
#   Read|write  'CURRENT_COMPILATION_SERVICE_MSG_COMPILER'
# Outputs:
#   Output either
#     - a TeamCity compilationStarted/compilationFinished service message
#     - or print to console
#     - or an error if teamcity_service_msg_compilationStarted is not closed using teamcity_service_msg_compilationFinished
#
# Reference:
#   - TeamCity doc: https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Compilation+Messages
#
# ToDo: assessment >> consider adding the logic to check "if run in teamcity" inside this function instead of relying on the IS_TEAMCITY_RUN env variable
# =================================================================================================================
function teamcity_service_msg_compilationStarted() {
  local THE_MSG=$1
  if [[ ${CURRENT_COMPILATION_SERVICE_MSG_COMPILER} ]]; then
    print_msg_error_and_exit "The TeamCity compilation service message ${MSG_DIMMED_FORMAT}${CURRENT_COMPILATION_SERVICE_MSG_COMPILER}${MSG_END_FORMAT} was not closed using function ${MSG_DIMMED_FORMAT}teamcity_service_msg_compilationFinished${MSG_END_FORMAT}."
  else
    export CURRENT_COMPILATION_SERVICE_MSG_COMPILER="${THE_MSG}"
  fi

  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[compilationStarted compiler='${MSG_BASE_TEAMCITY} ${THE_MSG}']"
  else
    echo && print_msg "${THE_MSG}" && echo
  fi
}

function teamcity_service_msg_compilationFinished() {
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[compilationFinished compiler='${MSG_BASE_TEAMCITY} ${CURRENT_COMPILATION_SERVICE_MSG_COMPILER}']"
  fi
  # Reset the variable since the bloc is closed
  unset CURRENT_COMPILATION_SERVICE_MSG_COMPILER
}
