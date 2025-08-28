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
  local msg_type=${1}
  local msg=${2}


  if [[ "${msg_type}" == "BASE" ]]; then
      msg_type=${MSG_BASE}
  elif [[ "${msg_type}" == "DONE" ]]; then
      msg_type=${MSG_DONE}
  elif [[ "${msg_type}" == "WARNING" ]]; then
    msg_type=${MSG_WARNING}
  elif [[ "${msg_type}" == "AWAITING_INPUT" ]]; then
    msg_type=${MSG_AWAITING_INPUT}
  else
    echo "from ${FUNCNAME[1]} › ${FUNCNAME[0]}: Unrecognized msg type '${msg_type}' (!)"
    exit 1
  fi

#  echo ""
  echo -e "${msg_type} ${msg}"
#  echo ""
}

function n2st::print_msg() {
    local msg=${1}
    n2st::_print_msg_formater "BASE" "${msg}"
}
function n2st::print_msg_done() {
    local msg=${1}
    n2st::_print_msg_formater "DONE" "${msg}"
}
function n2st::print_msg_warning() {
    local msg=${1}
    n2st::_print_msg_formater "WARNING" "${msg}"
}
function n2st::print_msg_awaiting_input() {
    local msg=${1}
    n2st::_print_msg_formater "AWAITING_INPUT" "${msg}"
}

# =================================================================================================
# Print formatted error message to prompt
#
# Usage:
#     $ n2st::print_msg_error_and_exit "<error msg string>"
#   or
#     $ n2st::print_msg_error_and_return "<error msg string>"
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
  local error_msg=$1

  echo ""
  echo -e "${MSG_ERROR} ${error_msg}" 1>&2
  # Note: The >&2 sends the echo output to standard error
  echo "Exiting now."
  echo ""
  exit 1
}

function n2st::print_msg_error_and_return() {
  local error_msg=$1

  echo ""
  echo -e "${MSG_ERROR} ${error_msg}" 1>&2
  # Note: The >&2 sends the echo output to standard error
  echo "Exiting function now."
  echo ""
  return 1
}

function n2st::print_msg_error() {
  local error_msg=$1

  echo -e "${MSG_ERROR} ${error_msg}" 1>&2
}

function n2st::print_msg_error_vspaced() {
  # For backward compatibility
  local error_msg=$1

  echo ""
  echo -e "${MSG_ERROR} ${error_msg}" 1>&2
  echo ""
}

# =================================================================================================
# Draw horizontal line the entire width of the terminal
# Source: https://web.archive.org/web/20230402083320/http://wiki.bash-hackers.org/snipplets/print_horizontal_line#a_line_across_the_entire_width_of_the_terminal
#
# Usage:
#   $ n2st::draw_horizontal_line_across_the_terminal_window [<symbol>] [<style>]
#
# Globals:
#   Read 'TERM' and 'COLUMNS' if available
# Arguments:
#   [<symbol>]      Symbol (a single character) for the line (default to '=')
#   [<style>]       Formating style (default to MSG_BASE_FORMAT)
# Outputs:
#   Show the terminal wide line
# Returns:
#   none
# =================================================================================================
function n2st::draw_horizontal_line_across_the_terminal_window() {
  local symbol="${1:-=}"
  local style="${2:-${MSG_BASE_FORMAT}}"
  local terminal_width
  local padding

  terminal_width=$( n2st::get_terminal_width_robust 80 )
  padding=$( n2st::generate_padding "${symbol}" "${terminal_width}" )
  echo -n -e  "${style}" 2>/dev/null
#  printf -- "%s\n" "${padding}"
  echo -e "$padding"
  echo -n -e  "${MSG_END_FORMAT}" 2>/dev/null
}

# =================================================================================================
# Print a formatted script header or footer
#
# Usage:
#   $ n2st::print_formated_script_header "<script name>" [<symbol>] [<style>]
#   ...
#   $ n2st::print_formated_script_footer "<script name>" [<symbol>] [<style>]
#
# Arguments:
#   <script name>   The name of the script that is executing the function. Will be print in the header
#   [<symbol>]      Symbole for the line, default to '='
#   [<style>]       Formating style (default to MSG_BASE_FORMAT)
# Outputs:
#   Print formated string to stdout
# Returns:
#   none
# =================================================================================================
function n2st::print_formated_script_header() {
  local script_name="${1}"
  local symbol="${2:-=}"
  local style="${3:-${MSG_BASE_FORMAT}}"
  echo
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}" "${style}"
  echo -e "Starting ${MSG_DIMMED_FORMAT}${script_name}${MSG_END_FORMAT}"
  echo
}

function n2st::print_formated_script_footer() {
  local script_name="${1}"
  local symbol="${2:-=}"
  local style="${3:-${MSG_BASE_FORMAT}}"
  echo
  echo -e "Completed ${MSG_DIMMED_FORMAT}${script_name}${MSG_END_FORMAT}"
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}" "${style}"
  echo
}


# =================================================================================================
# Print formated 'back to script' message
#
# Usage:
#   $ n2st::print_formated_back_to_script_msg "<script name>" [<symbol>] [<style>]
#
# Arguments:
#   <script name>   The name of the script that is executing the function. Will be print in the header
#   [<symbol>]      Symbole for the line, default to '='
#   [<style>]       Formating style (default to MSG_BASE_FORMAT)
# Outputs:
#   Print formated string to stdout
# Returns:
#   none
# =================================================================================================
function n2st::print_formated_back_to_script_msg() {
  local script_name="${1}"
  local symbol="${2:-=}"
  local style="${3:-${MSG_BASE_FORMAT}}"
  echo
  n2st::draw_horizontal_line_across_the_terminal_window "${symbol}" "${style}"
  echo -e "Back to ${MSG_DIMMED_FORMAT}${script_name}${MSG_END_FORMAT}"
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
  local file_name="${1}"
  echo
  echo -e "${MSG_DIMMED_FORMAT}"
  n2st::draw_horizontal_line_across_the_terminal_window .
  echo "${file_name} <<< EOF"
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
  local tmp_file_path="${1}"

  n2st::print_formated_file_preview_begin "${tmp_file_path}"
  echo
  more "${tmp_file_path}"
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

