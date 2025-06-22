#!/bin/bash
# =================================================================================================
# Import norlab-shell-script-tools function library and dependencies
#
# Usage in a interactive terminal session:
#
#   $ cd <path/to/norlab-shell-script-tools/>
#   $ PROJECT_PROMPT_NAME=MySuperProject
#   $ source import_norlab_shell_script_tools_lib.bash
#
# Usage from within a shell script:
#
#   #!/bin/bash
#   cd <my/superproject/root>/utilities/norlab-shell-script-tools
#   source import_norlab_shell_script_tools_lib.bash
#
# Note:
#   To assess non-interactive session behavior from the command line, execute:
#     bash -c "source import_norlab_shell_script_tools_lib.bash"
#
# =================================================================================================

MSG_ERROR_FORMAT="\033[1;31m"
MSG_END_FORMAT="\033[0m"

function n2st::source_lib() {

  # ....Setup......................................................................................
  local debug_log=false
  local tmp_cwd
  tmp_cwd=$(pwd)
  local script_path
  local target_path

  # ....Find path to script........................................................................
  if [[ -z ${N2ST_PATH} ]]; then
    # Note: can handle both sourcing cases
    #   i.e. from within a script or from an interactive terminal session
    # Check if running interactively
    if [[ $- == *i* ]]; then
      # Case: running in an interactive session
      target_path=$(realpath .)
    else
      # Case: running in an non-interactive session
      script_path="$(realpath -q "${BASH_SOURCE[0]:-.}")"
      target_path="$(dirname "${script_path}")"
    fi

    if [[ ${debug_log} == true ]]; then
      echo "
      BASH_SOURCE: ${BASH_SOURCE[*]}

      tmp_cwd: ${tmp_cwd}
      script_path: ${script_path}
      target_path: ${target_path}

      realpath: $(realpath .)
      \$0: $0
      "  >&3
    fi
  else
    target_path="${N2ST_PATH}"
  fi

  # ....Load environment variables from file.......................................................
  cd "${target_path}" || { echo "${target_path} unreachable" 1>&2 && exit 1; }
  set -o allexport
  source .env.n2st
  set +o allexport

  # ....Begin......................................................................................
  cd "${N2ST_PATH:?'[ERROR] env var not set!'}/src/function_library" || { echo "${N2ST_PATH} unreachable" 1>&2 && exit 1; }
  for each_file in "$(pwd)"/*.bash; do
    # shellcheck disable=SC1090
    source "${each_file}" || { echo "${each_file} unexpected error" 1>&2 && exit 1; }
  done

  # (NICE TO HAVE) ToDo: append lib to PATH (ref task NMO-414)
  #  cd "${N2ST_ROOT_DIR}/src/utility_scripts"
  #  PATH=$PATH:${N2ST_ROOT_DIR}/src/utility_scripts

  N2ST_VERSION="$(cat "${N2ST_PATH}"/version.txt)"
  export N2ST_VERSION

  # ....Teardown...................................................................................
  cd "${tmp_cwd}" || { echo "Return to original dir error" 1>&2 && exit 1; }
}

# ::::Main:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  echo -e "${MSG_ERROR_FORMAT}[ERROR]${MSG_END_FORMAT} This script must be sourced i.e.: $ source $(basename "$0")" 1>&2
  exit 1
else
  # This script is being sourced, ie: __name__="__source__"
  n2st::source_lib
fi
