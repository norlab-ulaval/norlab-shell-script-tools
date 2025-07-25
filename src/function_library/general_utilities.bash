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

# ....Pre-condition................................................................................
if [[ "$(basename "$(pwd)")" != "function_library" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'general_utilities.bash' script must be sourced from the 'function_library/'!\n Curent working directory is '$(pwd)'" 1>&2
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
# Seek and modify a string in a file (modify in place)
#
# Usage:
#   $ n2st::seek_and_modify_string_in_file "<string to seek>" "<change to string>" <path/to/file>
#
# Arguments:
#   "<string to seek>"
#   "<change to string>"
#   <path/to/file>
# Outputs:
#   none
# Returns:
#   1 on faillure, 0 otherwise
# =================================================================================================
function n2st::seek_and_modify_string_in_file() {

  local the_patern="${1}"
  local change_for="${2}"
  local file_path="${3}"

  if [[ ! -f "$file_path" ]]; then
    n2st::print_msg_error "File not found: $file_path"
    return 1
  fi

  # Note:
  #   - Character ';' is used as a delimiter
  #   - Keep -i flag for portability to Mac OsX (it's analogue to --in-place flag)
  #   - .bak is the backup extension convention and is required by -i
  sudo sed -i.bak "s;${the_patern};${change_for};" "${file_path}" || return 1
  sudo rm "${file_path}.bak" || return 1
  return 0
}

# =================================================================================================
# Print to stdout the current python version (major.minor).
#
# Usage:
#   $ n2st::set_which_python3_version
#   3.12
#
# =================================================================================================
function n2st::which_python3_version() {
    local python3_version
    python3_version=$(python3 -c 'import sys; version=sys.version_info; print(f"{version.major}.{version.minor}")') || return 1
    echo "${python3_version}"
    return 0
}

# =================================================================================================
# Fetch the current python version (major.minor) and set PYTHON3_VERSION env variable.
#
# Usage:
#   $ n2st::set_which_python3_version
#   do something else...
#   $ echo $PYTHON3_VERSION
#   3.12
#
# Globals:
#   write 'PYTHON3_VERSION'
# =================================================================================================
declare -x PYTHON3_VERSION
function n2st::set_which_python3_version() {
    PYTHON3_VERSION=$(n2st::which_python3_version) || return 1
    export PYTHON3_VERSION
    return 0
}

# =================================================================================================
# Print to stdout the host 'ARCH\OS' type:
#  - darwin\arm64
#  - linux\x86
#  - linux\arm64
#  - l4t\arm64
# with:
#  - Host OS being one of 'Linux', 'L4T' or 'Darwin'
#  - Host ARCH being one of 'aarch64', 'arm64' or 'x86_64'
#
# Usage:
#   $ n2st::which_architecture_and_os
#   linux\arm64
#
# Returns:
#   1 in case of unsupported processor architecture, 0 otherwise.
# =================================================================================================
# (NICE TO HAVE) ToDo: assessment >> check the convention used by docker >> os[/arch[/variant]]
#       linux/arm64/v8
#       darwin/arm64/v8
#       l4t/arm64/v8
#     ref: https://docs.docker.com/compose/compose-file/05-services/#platform
function n2st::which_architecture_and_os() {
  local image_arch_and_os
  if [[ $(uname -m) == "aarch64" ]]; then
    if uname -r | grep -q "tegra" 2>/dev/null; then
      image_arch_and_os='l4t/arm64'
    elif [[ $(uname) == "Linux" ]]; then
        image_arch_and_os='linux/arm64'
    else
      n2st::print_msg_error "Unsupported OS for aarch64 processor"
      return 1
    fi
  elif [[ $(uname -m) == "arm64" ]] && [[ $(uname) == "Darwin" ]]; then
    image_arch_and_os='darwin/arm64'
  elif [[ $(uname -m) == "x86_64" ]] && [[ $(uname) == "Linux" ]]; then
    image_arch_and_os='linux/x86'
  else
    n2st::print_msg_error "Unsupported processor architecture"
    return 1
  fi
  echo "${image_arch_and_os}"
  return 0
}

# =================================================================================================
# Check the host 'ARCH\OS' type and set the IMAGE_ARCH_AND_OS environment variable to:
#  - darwin\arm64
#  - linux\x86
#  - linux\arm64
#  - l4t\arm64
# depending on which architecture and OS type the script is running:
#  - Host OS being one of 'Linux', 'L4T' or 'Darwin'
#  - Host ARCH being one of 'aarch64', 'arm64' or 'x86_64'
#
# Usage:
#   $ n2st::set_which_architecture_and_os
#   do something else...
#   $ echo "$IMAGE_ARCH_AND_OS"
#   linux\arm64
#
# Globals:
#   write 'IMAGE_ARCH_AND_OS'
#
# Returns:
#   1 in case of unsupported processor architecture, 0 otherwize.
# =================================================================================================
declare -x IMAGE_ARCH_AND_OS
function n2st::set_which_architecture_and_os() {
  IMAGE_ARCH_AND_OS=$(n2st::which_architecture_and_os) || return 1
  export IMAGE_ARCH_AND_OS
  return 0
}

# ====legacy API support===========================================================================
function seek_and_modify_string_in_file() {
  n2st::seek_and_modify_string_in_file "$@"
}

function set_which_python3_version() {
  n2st::set_which_python3_version "$@"
}

function set_which_architecture_and_os() {
  n2st::set_which_architecture_and_os "$@"
}
