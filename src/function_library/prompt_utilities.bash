#!/bin/bash
#
# Library of function related to console formatting
#
# Requirement: This script must be sourced from directory 'function_library'
#
# Usage:
#   $ cd <path/to/project>/norlab-shell-script-tools/src/function_library
#   $ source ./prompt_utilities.bash
#


# ....Pre-condition................................................................................
if [[ "$(basename "$(pwd)")" != "function_library" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'prompt_utilities.bash' script must be sourced from the 'function_library/'!\n Curent working directory is '$(pwd)'" 1>&2
  echo '(press any key to exit)'
  read -rn 1
  exit 1
fi


# ....Load environment variables from file.........................................................
set -o allexport
source .env.msg_style
set +o allexport

# ....Load dependencies............................................................................
if [[ -z "$( declare -f n2st::generate_padding )"  ]] || [[ -z "$( declare -f n2st::get_terminal_width_robust )"  ]]; then
  source "./terminal_splash.bash" || exit 1
fi


# =================================================================================================
# Print formatted message to prompt
#
# Usage:
#   $ _print_msg "<mesageType>" "<the message string>"
#
# Arguments:
#   <mesageType>          The message type: "BASE", "DONE", "WARNING", "AWAITING_INPUT"
#   <the message string>  The message string
# Outputs:
#   The formated message to stdout
# Returns:
#   none
# =================================================================================================
function n2st::_print_msg_formater() {
  local MSG_TYPE=${1}
  local MSG=${2}


  if [[ "${MSG_TYPE}" == "BASE" ]]; then
      MSG_TYPE=${MSG_BASE}
  elif [[ "${MSG_TYPE}" == "DONE" ]]; then
      MSG_TYPE=${MSG_DONE}
  elif [[ "${MSG_TYPE}" == "WARNING" ]]; then
    MSG_TYPE=${MSG_WARNING}
  elif [[ "${MSG_TYPE}" == "AWAITING_INPUT" ]]; then
    MSG_TYPE=${MSG_AWAITING_INPUT}
  else
    echo "from ${FUNCNAME[1]} › ${FUNCNAME[0]}: Unrecognized msg type '${MSG_TYPE}' (!)"
    exit 1
  fi

#  echo ""
  echo -e "${MSG_TYPE} ${MSG}"
#  echo ""
}

function n2st::print_msg() {
    local MSG=${1}
    n2st::_print_msg_formater "BASE" "${MSG}"
}
function n2st::print_msg_done() {
    local MSG=${1}
    n2st::_print_msg_formater "DONE" "${MSG}"
}
function n2st::print_msg_warning() {
    local MSG=${1}
    n2st::_print_msg_formater "WARNING" "${MSG}"
}
function n2st::print_msg_awaiting_input() {
    local MSG=${1}
    n2st::_print_msg_formater "AWAITING_INPUT" "${MSG}"
}

# =================================================================================================
# Print formatted error message to prompt
#
# Usage:
#     $ n2st::print_msg_error_and_exit "<error msg string>"
#   or
#     $ n2st::print_msg_error "<error msg string>"
#
# Arguments:
#   <error msg string>  The error message to print
# Outputs:
#   The formatted error message to to stderr
# Returns:
#   none
# =================================================================================================
function n2st::print_msg_error_and_exit() {
  local ERROR_MSG=$1

  echo ""
  echo -e "${MSG_ERROR}: ${ERROR_MSG}" 1>&2
  # Note: The >&2 sends the echo output to standard error
  echo "Exiting now."
  echo ""
  exit 1
}

function n2st::print_msg_error() {
  local ERROR_MSG=$1

  echo ""
  echo -e "${MSG_ERROR}: ${ERROR_MSG}" 1>&2
  echo ""
}

# =================================================================================================
# Draw horizontal line the entire width of the terminal
# Source: https://web.archive.org/web/20230402083320/http://wiki.bash-hackers.org/snipplets/print_horizontal_line#a_line_across_the_entire_width_of_the_terminal
#
# Usage:
#   $ n2st::draw_horizontal_line_across_the_terminal_window [<symbol>]
#
# Globals:
#   Read 'TERM' and 'COLUMNS' if available
# Arguments:
#   [<symbol>] Symbol (a single character) for the line, default to '='
# Outputs:
#   The screen wide line
# Returns:
#   none
# =================================================================================================
function n2st::draw_horizontal_line_across_the_terminal_window() {
  local symbol="${1:-=}"
  local terminal_width
  local padding

  terminal_width=$( n2st::get_terminal_width_robust 80 )
  padding=$( n2st::generate_padding "${symbol}" "${terminal_width}" )

#  printf -- "%s\n" "${padding}"
  echo -e "$padding"
}

# =================================================================================================
# Print a formatted script header or footer
#
# Usage:
#   $ n2st::print_formated_script_header "<script name>" [<symbol>]
#   $ n2st::print_formated_script_footer "<script name>" [<symbol>]
#
# Arguments:
#   <script name>   The name of the script that is executing the function. Will be print in the header
#   [<symbol>]      Symbole for the line, default to '='
# Outputs:
#   Print formated string to stdout
# Returns:
#   none
# =================================================================================================
function n2st::print_formated_script_header() {
  local SCRIPT_NAME="${1}"
  local symbol="${2:-=}"
  echo
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}"
  echo -e "Starting ${MSG_DIMMED_FORMAT}${SCRIPT_NAME}${MSG_END_FORMAT}"
  echo
}

function n2st::print_formated_script_footer() {
  local SCRIPT_NAME="${1}"
  local symbol="${2:-=}"
  echo
  echo -e "Completed ${MSG_DIMMED_FORMAT}${SCRIPT_NAME}${MSG_END_FORMAT}"
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}"
  echo
}


# =================================================================================================
# Print formated 'back to script' message
#
# Usage:
#   $ n2st::print_formated_back_to_script_msg "<script name>" [<symbol>]
#
# Arguments:
#   <script name>   The name of the script that is executing the function. Will be print in the header
#   [<symbol>]      Symbole for the line, default to '='
# Outputs:
#   Print formated string to stdout
# Returns:
#   none
# =================================================================================================
function n2st::print_formated_back_to_script_msg() {
  local SCRIPT_NAME="${1}"
  local symbol="${2:-=}"
  echo
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}"
  echo -e "Back to ${MSG_DIMMED_FORMAT}${SCRIPT_NAME}${MSG_END_FORMAT}"
  echo
}

# =================================================================================================
# Print formatted file preview
#
# Usage:
#   $ n2st::print_formated_file_preview_begin "<file name>"
#   $ <the_command_which_echo_the_file>
#   $ n2st::print_formated_file_preview_end
#
# Arguments:
#   <file name>   The name of the file
# Outputs:
#   Print formated file preview to stdout
# Returns:
#   none
# =================================================================================================
function n2st::print_formated_file_preview_begin() {
  local FILE_NAME="${1}"
  echo
  echo -e "${MSG_DIMMED_FORMAT}"
  n2st::draw_horizontal_line_across_the_terminal_window .
  echo "${FILE_NAME} <<< EOF"
}

function n2st::print_formated_file_preview_end() {
  echo "EOF"
  n2st::draw_horizontal_line_across_the_terminal_window .
  echo -e "${MSG_END_FORMAT}"
  echo
}


# =================================================================================================
# Print file to console, formated in a way that standout from other console print
#
# Usage:
#   $ n2st::preview_file_in_promt <path/to/file>
#
# Arguments:
#   <path/to/file>
# Outputs:
#   Formated preview of a file
# Returns:
#   none
# =================================================================================================
function n2st::preview_file_in_promt() {
  local TMP_FILE_PATH="${1}"

  n2st::print_formated_file_preview_begin "${TMP_FILE_PATH}"
  echo
  more "${TMP_FILE_PATH}"
  echo
  n2st::print_formated_file_preview_end

}

# ====legacy API support===========================================================================
function print_msg() {
  n2st::print_msg "$@"
}

function print_msg_done() {
  n2st::print_msg_done "$@"
}

function print_msg_warning() {
  n2st::print_msg_warning "$@"
}

function print_msg_awaiting_input() {
  n2st::print_msg_awaiting_input "$@"
}

function print_msg_error_and_exit() {
  n2st::print_msg_error_and_exit "$@"
}

function print_msg_error() {
  n2st::print_msg_error "$@"
}

function draw_horizontal_line_across_the_terminal_window() {
  n2st::draw_horizontal_line_across_the_terminal_window "$@"
}

function print_formated_script_header() {
  n2st::print_formated_script_header "$@"
}

function print_formated_script_footer() {
  n2st::print_formated_script_footer "$@"
}

function print_formated_back_to_script_msg() {
  n2st::print_formated_back_to_script_msg "$@"
}

function print_formated_file_preview_begin() {
  n2st::print_formated_file_preview_begin "$@"
}

function print_formated_file_preview_end() {
  n2st::print_formated_file_preview_end "$@"
}

function preview_file_in_promt() {
  n2st::preview_file_in_promt "$@"
}

