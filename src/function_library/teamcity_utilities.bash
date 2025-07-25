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


# ....Pre-condition................................................................................
if [[ "$(basename "$(pwd)")" != "function_library" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'teamcity_utilities.bash' script must be sourced from the 'function_library/'!\n Curent working directory is '$(pwd)'" 1>&2
  echo '(press any key to exit)'
  read -r -n 1
  exit 1
fi

# ....Load environment variables from file.........................................................
set -o allexport
source .env.msg_style
set +o allexport

# ....Load helper function.........................................................................
source ./prompt_utilities.bash

# =================================================================================================
# Check if the script is executed in JetBrains TeamCity continuous integration/deployment server
# and set the IS_TEAMCITY_RUN environment variable accordingly, 'true' or 'false'
#
# Usage:
#   $ n2st::set_is_teamcity_run_environment_variable
#
# Globals:
#   [Read]  'TEAMCITY_VERSION'
#   [write] 'IS_TEAMCITY_RUN'
# Returns:
#   none
# =================================================================================================
function n2st::set_is_teamcity_run_environment_variable() {
  if [[ ${TEAMCITY_VERSION} ]] ; then
    IS_TEAMCITY_RUN=true
  else
    IS_TEAMCITY_RUN=false
  fi
  export IS_TEAMCITY_RUN
}

# =================================================================================================
# Escape string for TeamCity Service Message compliance
# Ref: https://www.jetbrains.com/help/teamcity/service-messages.html#Escaped+Values
#
# Usage:
#   echo -e "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} $(n2st::teamcity_service_msg_str_formater "${the_msg}")']"
#
# Note:
# - Uses only standard POSIX features that work on both Ubuntu and macOS
# =================================================================================================
function n2st::teamcity_service_msg_str_formater() {
  local input="$1"
  printf '%s' "$input" | sed -e 's/|/||/g' -e 's/\[/|[/g' -e 's/\]/|]/g' -e "s/'/|'/g"
}


# =================================================================================================
# Send TeamCity blockOpened/blockClosed service message
#   or print the message to console when executed outside a TeamCity Agent run.
#
# Usage:
#   $ n2st::teamcity_service_msg_blockOpened "<theMessage>"
#   $ ... many steps ...
#   $ n2st::teamcity_service_msg_blockClosed
#
# Globals:
#   Read        'IS_TEAMCITY_RUN'
#   Read|write  'CURRENT_BLOCK_SERVICE_MSG'
# Outputs:
#   Output either
#     - a TeamCity blockOpened/blockClosed service message
#     - or print to console
#     - or an error if n2st::teamcity_service_msg_blockOpened is not closed using n2st::teamcity_service_msg_blockClosed
#
# Reference:
#   - TeamCity doc: https://www.jetbrains.com/help/teamcity/service-messages.html#Blocks+of+Service+Messages
#
# ToDo: assessment >> consider adding the logic to check "if run in teamcity" inside this function instead of relying on the IS_TEAMCITY_RUN env variable
# (NICE TO HAVE) ToDo: refactor (ref task NMO-341 refactor `n2st::teamcity_service_msg_blockOpened`  to use dynamic env variable name so that we can nest fct call)
# =================================================================================================
function n2st::teamcity_service_msg_blockOpened() {
  local the_msg=$1
  if [[ ${CURRENT_BLOCK_SERVICE_MSG} ]]; then
    n2st::print_msg_error_and_exit "The TeamCity bloc service message ${MSG_DIMMED_FORMAT}${CURRENT_BLOCK_SERVICE_MSG}${MSG_END_FORMAT} was not closed using function ${MSG_DIMMED_FORMAT}n2st::teamcity_service_msg_blockClosed${MSG_END_FORMAT}."
  else
    export CURRENT_BLOCK_SERVICE_MSG
    CURRENT_BLOCK_SERVICE_MSG="$(n2st::teamcity_service_msg_str_formater "${the_msg}")"
  fi

  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} $(n2st::teamcity_service_msg_str_formater "${the_msg}")']"
  else
    n2st::print_msg "${the_msg}"
  fi
}

function n2st::teamcity_service_msg_blockClosed() {
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} ${CURRENT_BLOCK_SERVICE_MSG}']"
  fi
  # Reset the variable since the bloc is closed
  unset CURRENT_BLOCK_SERVICE_MSG
}

# =================================================================================================
# Send TeamCity blockOpened/blockClosed service message (explicit blockClosed msg version)
#   or print the message to console when executed outside a TeamCity Agent run.
#
# Usage:
#   $ n2st::teamcity_service_msg_blockOpened_v2 "<theMessage>"
#   $ ... many steps ...
#   $ n2st::teamcity_service_msg_blockClosed_v2 "<theMessage>"
#
# Globals:
#   Read        'IS_TEAMCITY_RUN'
#   Read|write  'CURRENT_BLOCK_SERVICE_MSG'
# Outputs:
#   Output either
#     - a TeamCity blockOpened/blockClosed service message
#     - or print to console
#
# Reference:
#   - TeamCity doc: https://www.jetbrains.com/help/teamcity/service-messages.html#Blocks+of+Service+Messages
# =================================================================================================
function n2st::teamcity_service_msg_blockOpened_v2() {
  local the_msg=$1
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} $(n2st::teamcity_service_msg_str_formater "${the_msg}")']"
  else
    n2st::print_msg "${the_msg}"
  fi
}

function n2st::teamcity_service_msg_blockClosed_v2() {
  local the_msg=$1
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} $(n2st::teamcity_service_msg_str_formater "${the_msg}")']"
  fi
}


# =================================================================================================
# Send TeamCity compilationStarted/compilationFinished service message
#   or print the message to console when executed outside a TeamCity Agent run.
#
# Usage:
#   $ n2st::teamcity_service_msg_compilationStarted "<theMessage>"
#   $ ... many compilation steps ...
#   $ n2st::teamcity_service_msg_compilationFinished
#
# Globals:
#   Read        'IS_TEAMCITY_RUN'
#   Read|write  'CURRENT_COMPILATION_SERVICE_MSG_COMPILER'
# Outputs:
#   Output either
#     - a TeamCity compilationStarted/compilationFinished service message
#     - or print to console
#     - or an error if n2st::teamcity_service_msg_compilationStarted is not closed using n2st::teamcity_service_msg_compilationFinished
#
# Reference:
#   - TeamCity doc: https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Compilation+Messages
#
# ToDo: assessment >> consider adding the logic to check "if run in teamcity" inside this function instead of relying on the IS_TEAMCITY_RUN env variable
# =================================================================================================
function n2st::teamcity_service_msg_compilationStarted() {
  local the_msg=$1
  if [[ ${CURRENT_COMPILATION_SERVICE_MSG_COMPILER} ]]; then
    n2st::print_msg_error_and_exit "The TeamCity compilation service message ${MSG_DIMMED_FORMAT}${CURRENT_COMPILATION_SERVICE_MSG_COMPILER}${MSG_END_FORMAT} was not closed using function ${MSG_DIMMED_FORMAT}n2st::teamcity_service_msg_compilationFinished${MSG_END_FORMAT}."
  else
    export CURRENT_COMPILATION_SERVICE_MSG_COMPILER="${the_msg}"
  fi

  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[compilationStarted compiler='${MSG_BASE_TEAMCITY} ${the_msg}']"
  else
    n2st::print_msg "${the_msg}"
  fi
}

function n2st::teamcity_service_msg_compilationFinished() {
  if [[ ${IS_TEAMCITY_RUN} == true ]]; then
    echo -e "##teamcity[compilationFinished compiler='${MSG_BASE_TEAMCITY} ${CURRENT_COMPILATION_SERVICE_MSG_COMPILER}']"
  fi
  # Reset the variable since the bloc is closed
  unset CURRENT_COMPILATION_SERVICE_MSG_COMPILER
}


# ====legacy API support===========================================================================
function set_is_teamcity_run_environment_variable() {
  n2st::set_is_teamcity_run_environment_variable "$@"
}

function teamcity_service_msg_blockOpened() {
  n2st::teamcity_service_msg_blockOpened "$@"
}

function teamcity_service_msg_blockClosed() {
  n2st::teamcity_service_msg_blockClosed "$@"
}

function teamcity_service_msg_compilationStarted() {
  n2st::teamcity_service_msg_compilationStarted "$@"
}

function teamcity_service_msg_compilationFinished() {
  n2st::teamcity_service_msg_compilationFinished "$@"
}

