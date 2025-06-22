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

  # ....Find path to script........................................................................
  target_path=$( git rev-parse --show-toplevel )
  # Check if it was sourced from whitin the N2ST repository
  if [[ "$( basename "${target_path}" .git)" != "$(basename "$(pwd)" )"  ]]; then
    echo -e "${MSG_ERROR_FORMAT}[NBS error]${MSG_END_FORMAT} This script must be sourced from whitin the N2ST repository. cwd: $PWD" 1>&2
    return 1
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
  cd "${target_path}" || { echo "Return to original dir error" 1>&2 && exit 1; }
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
