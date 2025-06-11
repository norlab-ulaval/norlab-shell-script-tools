#!/bin/bash
#
# Requirement: This script must be executed from project root 'NorLab-TeamCity-Server-infrastructure'
#
# Usage:
#   $ source function_library/terminal_splash.bash
#
#set -e # (NICE TO HAVE) ToDo: fixme!! >> script exit if "set -e" is enable
#set -v


# =================================================================================================
# Dynamic printf centering tool. Centering based on the terminal screen width at runtime.
#
# Usage:
#   $ source function_library/terminal_splash.bash
#   $ n2st::echo_centering_str <theString> <theStyle> <thePadCharacter> [<fill_left>] [<fill_right>]
#
#   $ n2st::echo_centering_str "···•· ${title} ··•••" "\033[1;37m" "\033[0m·"
#
# Globals: 
#   none
# Arguments:
#   <theString>           The string to center
#   <theStyle>            The style appended at the begining of the line (default to "\033[1;37m")
#   <thePadCharacter>     The padding character to use (default to "\033[0m·")
# Globals:
#   read LC_CTYPE
#   read LC_ALL
#   read TEAMCITY_VERSION
#   read IS_TEAMCITY_RUN
#   read TERM
# Outputs:
#   Output the line to STDOUT
# Returns:
#   none
# =================================================================================================
function n2st::echo_centering_str() {
  # (NICE TO HAVE) ToDo:
  #     - var TERM should be setup in Dockerfile.dependencies.
  #     - print a warning message if TERM is not set

  # ....Pre-check and set default locale...........................................................
  # Add locale handling
  local current_lc_ctype="${LC_CTYPE:-}"

  # Try using a default safe locale if the current one fails
  local safe_locale="C.UTF-8"
  if locale -a 2>/dev/null | grep -q "${safe_locale}"; then
    export LC_CTYPE="${safe_locale}"
  elif locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
    export LC_CTYPE="en_US.UTF-8"
  else
    # Fallback to C locale which is guaranteed to exist
    export LC_CTYPE="C"
  fi

  # ....Positional arguments.......................................................................
  local the_str_pre=${1:?'Missing a mandatory parameter error'}
#  local the_str=${1:?'Missing a mandatory parameter error'}
  printf -v the_str -- "%b" "${the_str_pre}" 2>/dev/null
  local the_style="${2:?'Missing a mandatory parameter error'}"
  local the_pad_cha="${3:?'Missing a mandatory parameter error'}"
  local fill_left="${4:-""}"
  local fill_right="${5:-""}"
  local str_len=${#the_str}

  # ....Formating..................................................................................
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    local the_style_off="[0m"
  else
    local the_style_off="\033[0m"
  fi

  # ....Set terminal env var.......................................................................
  # Ref https://bash.cyberciti.biz/guide/$TERM_variable
  tput_flag=("-T" "$TERM")
  if [[ -z ${TERM} ]]; then
    tput_flag=("-T" "xterm-256color")
  elif [[ ${TERM} == dumb ]]; then
    # "dumb" is the one set on TeamCity Agent
    #unset tput_flag
    tput_flag=("-T" "xterm-256color")
  fi


  # ....Begin......................................................................................
  local terminal_width
#  terminal_width=$(tput ${tput_flag} cols)
  # shellcheck disable=SC2086
  terminal_width="${COLUMNS:-$(tput "${tput_flag[@]}" cols)}"
  local total_padding_len=$(( ${terminal_width} - ${str_len} ))
  local single_side_padding_len=$(( ${total_padding_len} / 2 ))
  local pad
  pad=$(printf -- "$the_pad_cha%.0s" $(seq $single_side_padding_len))

  # Note: adding `2>/dev/null` at the end is a quick-hack. Will need a more robust solution.
  #       ref task N2ST-2 fix: splash LC_TYPE related error
  LC_ALL='' LC_CTYPE=en_US.UTF-8 printf -- "%b%b%s%b%s%b%b\n" "${the_style}" "${fill_left}" "${pad}" "${the_str}" "${pad}" "${fill_right}" "${the_style_off}" 2>/dev/null

  # ....Teardown...................................................................................
  # Restore original locale settings
  export LC_CTYPE="${current_lc_ctype}"
  return 0
}


# =================================================================================================
# SNOW terminal splash screen
#
# Credit: ASCII art generated using image generator at https://asciiart.club
#
# Usage:
#
#   $ source function_library/terminal_splash.bash
#   $ n2st::snow_splash [title [url]]
#
# Example:
#
#   $ n2st::snow_splash "NorLab" "https://github.com/norlab-ulaval"
#
# Globals:
#   none
# Arguments:
#   <title>   The title printed in the center of the splash screen (default 'NorLab')
#   <url>     The url printed at the bottom of the splash screen (default 'https://github.com/norlab-ulaval')
# Outputs:
#   Output the splash screen to STDOUT
# Returns:
#   none
#
# References:
#   - Bash tips: Colors and formatting (ANSI/VT100 Control sequences):
#     https://misc.flogisoft.com/bash/tip_colors_and_formatting#bash_tipscolors_and_formatting_ansivt100_control_sequences
#   - ASCII art generated using image generator at https://asciiart.club
#   - https://lachlanarthur.github.io/Braille-ASCII-Art/
#
# Dev workflow: run the following command
#
#   $ source build_system/function_library/terminal_splash.bash \
#      && n2st::snow_splash "NorLab" "https://github.com/norlab-ulaval"
#
# =================================================================================================
function n2st::snow_splash() {
  local title=${1:-'NorLab'}
  local optional_url=${2:-'https://github.com/norlab-ulaval'}

  local fill_t=''
  local fill_u=''
  if [[ ${IS_TEAMCITY_RUN} == true ]] || [[ ${TEAMCITY_VERSION} ]]; then
    local fill_t='······'
    local fill_u='      '
  fi

  # Formatting
  #   - 1=Bold/bright
  #   - 2=Dim
  #   - 4=underline
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    local title_formatting="[1m"
    local snow_formatting="[2m"
    local url_formatting="[2m"
  else
    local title_formatting="\033[1m"
    local snow_formatting="\033[2m"
    local url_formatting="\033[2m"
  fi

  echo " "
  echo " "
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⢿⣷⣼⣿⣤⣿⡗⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⢀⣤⡀⣿⣿⠀⠀⠉⣿⣿⡿⠁⠀⠀⣿⡟⣀⣤⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠙⣻⣿⣿⣧⠀⠀⢸⣿⠀⠀⢀⣿⣿⣿⣟⠉⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠘⠛⠛⠉⠉⠙⠿⣿⣾⣿⣷⣿⠟⠉⠉⠙⠛⠛⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·" "${fill_t}" "${fill_t}"
  n2st::echo_centering_str "⢠⣶⣤⣄⣀⣤⣶⣿⢿⣿⢿⣿⣶⣄⣀⣤⣤⣶⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⣨⣿⣿⣿⡟⠁⠀⢸⣿⠀⠀⠉⣿⣿⣿⣯⣀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠈⠛⠁⣿⣿⢀⠀⣠⣿⣿⣷⡀⠀⠈⣿⣧⠉⠛⢀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⣾⡿⢻⣿⠙⣿⡷⠀⠈⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  echo " "
  n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " " "${fill_u}" "${fill_u}"
  n2st::echo_centering_str "${optional_url}" "${url_formatting}" " " "${fill_u}" "${fill_u}"
  echo " "
  echo " "
}

# =================================================================================================
# NorLab Terminal splash screen
#
# Credit: ASCII art generated using image generator at https://asciiart.club
#
# Usage:
#
#   $ source function_library/terminal_splash.bash
#   $ n2st::norlab_splash [title [url [splash-type]] ]
#
# Example:
#
#   $ n2st::norlab_splash "NorLab" "https://github.com/norlab-ulaval"
#
# Globals:
#   none
# Arguments:
#   <title>         The title printed in the center of the splash screen (default 'NorLab')
#   <url>           The url printed at the bottom of the splash screen (default 'https://github.com/norlab-ulaval')
#   <splash-type>   The style of presentation: small, negative or big (default 'negative')
# Outputs:
#   Output the splash screen to STDOUT
# Returns:
#   none
#
# References:
#   - Bash tips: Colors and formatting (ANSI/VT100 Control sequences):
#     https://misc.flogisoft.com/bash/tip_colors_and_formatting#bash_tipscolors_and_formatting_ansivt100_control_sequences
#   - ASCII art generated using image generator at https://asciiart.club
#   - https://lachlanarthur.github.io/Braille-ASCII-Art/
#
# Dev workflow: run the following command
#
#   $ source src/function_library/terminal_splash.bash \
#      && n2st::norlab_splash "NorLab" "https://github.com/norlab-ulaval"
#
# =================================================================================================
function n2st::norlab_splash() {
  local title=${1:-'NorLab'}
  local optional_url=${2:-'https://github.com/norlab-ulaval'}
  local splash_type=${3:-negative} # Option: small, negative or big

  local fill_t=''
  local fill_u=''
  if [[ ${IS_TEAMCITY_RUN} == true ]] || [[ ${TEAMCITY_VERSION} ]]; then
    local fill_t='······'
    local fill_u='      '
  fi

  # Formatting
  #   - 1=Bold/bright
  #   - 2=Dim
  #   - 4=underline
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    local title_formatting="[1m"
    local snow_formatting="[2m"
    local url_formatting="[2m"
  else
    local title_formatting="\033[1m"
    local snow_formatting="\033[2m"
    local url_formatting="\033[2m"
  fi


  #  echo -e "splash_type=${splash_type}"
  if [[ ${splash_type} == small ]]; then

    echo " "
    echo " "
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣄⠀⠀⠀⣼⣿⣿⣿⣿⠀⠀⠀⢀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⢛⣩⣭⣶⣶⠒⣶⣦⣭⣉⠛⢿⣿⣿⣿⠂⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⣠⠟⣭⣾⣿⣿⣿⡿⠙⢿⠀⠿⠉⣿⣿⣿⣿⣶⣍⠻⣄⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⣴⣿⣿⠟⣶⣿⣿⣿⣿⣿⣿⠉⠻⣶⠀⣶⠛⠉⠟⣛⣛⣛⣛⠻⢦⠻⣿⣿⣦⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠘⣿⣿⢡⡋⠙⠿⠀⣿⡀⢸⡟⠙⢷⣤⠀⣤⠞⠾⢿⡇⢰⡟⠀⠟⠉⢻⡟⣾⣿⠗⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⢰⢁⣿⣿⠛⠀⣀⠈⠀⢸⡇⢸⣶⣄⠀⣤⠘⡀⢸⠃⠈⠀⣀⠀⠛⣿⣼⠸⡄⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⣶⣾⣿⣾⣿⣿⣿⠉⢀⣤⡶⠒⠀⠈⠛⢿⠀⠛⠚⠀⠀⠒⣶⣤⡀⢙⡿⣴⣿⣧⣿⣦⣤" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·" "${fill_t}" "${fill_t}"
    n2st::echo_centering_str "⠀⣿⣿⣏⣿⣿⣿⣿⡿⣿⣄⠀⠛⣿⡿⠛⠀⠀⠀⠒⣶⡮⠛⠢⠿⣛⣭⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠈⠉⣿⢹⣿⣿⠛⢶⣤⡀⠉⠉⠀⢰⣿⣿⠀⣿⣷⡀⠀⠉⠉⣀⣤⡾⠛⣿⣿⡏⡿⠛⠉" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⣨⣆⣿⣿⠟⠀⠀⣠⠀⢸⡇⠘⠉⣀⠀⡀⠉⠀⢸⡆⢰⡄⠀⠐⠿⣿⣿⣼⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠺⣿⣿⣆⢷⣾⣿⣀⣿⣀⣾⣷⡾⠋⢀⠀⠈⠛⣶⣿⣇⣸⣿⣀⣿⣶⡿⣴⣿⣿⠆⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠙⡿⠿⢷⡙⣿⣿⣿⣿⣿⣿⣶⠟⠉⠀⠉⠿⣶⣿⣿⣿⣿⣿⣿⢫⣿⣿⣿⠃⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠈⣿⣬⡛⣿⣿⣿⣿⣶⣿⠀⣿⣶⣿⣿⣿⡿⢛⣵⣿⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠘⠿⣿⣿⣿⠓⠶⣭⣭⣉⣉⣉⣭⣭⠶⢾⣿⣿⣿⠿⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⣿⣿⣿⣿⠃⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    echo " "
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    echo " "
    echo " "

  elif [[ ${splash_type} == big ]]; then

    echo " "
    echo " "
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣷⣤⡀⠀⠀⣀⣰⣿⣿⣿⣿⣿⣿⣿⣀⠀⠀⠀⢀⣴⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⠿⠛⣋⣉⣩⣤⣤⠤⠤⣤⣬⣍⣉⡙⠛⠶⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⠿⢛⣡⣴⣾⣿⣿⣿⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⣿⣶⣦⣌⡛⠿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠛⣡⣶⣿⣿⣿⣿⣿⣿⣟⠁⠉⠻⠀⠀⠟⠉⠈⣻⣿⣿⣿⣿⣿⣿⣶⣌⠛⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⣴⣿⣷⣶⣶⠋⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⠻⢷⣦⡀⠀⠀⢀⣴⡾⠟⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠙⣦⣤⣴⣶⣦⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⢀⣼⣿⣿⣿⡟⢡⣾⣿⣿⠿⠿⣿⣿⣿⣿⣿⣧⣀⠀⠉⠻⠀⠀⠟⠉⠀⡀⢈⣥⡴⣶⣶⣶⠶⠤⣭⣍⣓⡈⠻⠿⠿⢿⣧⡀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠺⣿⣿⣿⠟⣰⠏⠙⠻⣿⡀⠀⣿⡇⠀⢸⣿⠛⠻⢷⣦⣀⠀⠀⣀⣴⠎⣴⣿⣿⡇⠀⢸⣿⠀⢀⡿⠟⠋⠹⣿⡟⣰⣿⣿⡷⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠈⢻⡟⢰⣿⣶⣤⣀⠀⠁⠀⢹⡇⠀⢸⣿⠀⢀⡀⠈⠙⠀⠀⠋⠁⢸⠀⠀⣿⡇⠀⢸⡇⠀⠈⠀⣀⣤⣶⡿⢀⢻⣿⠟⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⡿⢀⣿⣿⣟⠛⠉⠀⣀⣀⡀⠀⠀⠸⣿⠀⢸⣿⣶⣤⠀⠀⣤⣶⢸⡇⠀⣿⠇⠀⠀⢀⣀⣀⠀⠉⠛⣿⢃⣿⡄⢿⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⢀⣀⣤⣼⡇⣸⣿⣿⣿⣦⣶⠿⠛⠉⠀⢀⣠⡀⠀⠀⠘⢿⣿⣿⠀⠀⣿⠏⡸⠃⠀⠀⢀⣄⡀⠀⠉⠛⠿⣶⣴⠇⣼⣿⣇⢸⣇⡀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⣿⣿⣿⣿⠁⣿⣿⣿⣿⣿⣿⣄⣠⣴⡾⠟⠉⠀⢀⣤⣄⠀⠈⠙⠀⠀⠁⠀⠀⣠⣤⡀⠀⠉⠻⢷⣦⣄⣠⡿⢃⣾⣿⣿⣿⠀⣿⣿⣿⣶" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·" "${fill_t}" "${fill_t}"
    n2st::echo_centering_str "⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⣿⣿⣏⡀⠀⠐⠾⣿⣿⣿⡿⠒⠀⠀⠀⠀⠠⢴⣶⣦⣍⠳⠦⣄⣼⡿⠟⣋⣴⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⠁⠉⠛⠿⣶⣤⡀⠀⠉⠁⠀⣠⣴⠀⠀⣦⣀⠀⠈⠉⠀⢀⣤⣶⠶⠒⠉⠈⣿⣿⣿⣿⣿⣿⢀⣿⣿⣿⣿" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠈⢹⡇⢹⣿⣿⣿⠛⠛⠿⣶⣤⡀⠀⠉⠀⢀⠀⢰⣿⣿⣿⠀⠀⣿⣿⣿⠀⠀⡀⠀⠉⠀⢀⣤⣶⠿⠛⠻⣿⣿⣿⡏⢸⡟⠛⠉⠁" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⣷⠘⣿⣿⣷⣦⣄⠀⠀⠁⠀⡀⠀⢸⣿⠀⢸⡿⠟⠋⠀⠀⠙⠻⢿⠀⠀⣿⡇⠀⢀⠀⠈⠀⠀⣠⣴⣿⣿⣿⠁⣾⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⣴⣿⣧⠹⣿⠟⠉⠀⢀⠀⠀⣼⡇⠀⢸⣿⠀⠀⠀⣠⣴⠀⠀⣦⣀⠀⠀⠀⣿⡇⠀⢸⡇⠀⢀⡀⠀⠙⠻⣿⠇⣼⣧⡀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⢾⣿⣿⣿⣦⠹⣧⣴⣾⣿⠀⠀⣿⡇⠀⢸⣿⣦⣶⠿⠋⠁⠀⠀⠈⠛⠿⣶⣴⣿⡇⠀⢸⣿⠀⠈⣿⣷⣤⣼⠏⣴⣿⣿⣿⡦⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠈⢻⣿⣿⣿⣧⡘⢿⣿⣿⣿⣶⣿⣿⣿⣿⣿⡏⠁⢀⣠⣶⠀⠀⣶⣄⡀⠈⢻⣿⣿⣿⣿⣿⣶⣿⣿⣿⡿⢃⣼⣿⣿⣿⡟⠁⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠻⠿⠟⠛⠻⣄⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠿⠋⠀⠀⠀⠀⠙⠿⣶⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣠⠿⠿⢿⣿⠟⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⣤⡙⠿⣿⣿⣿⣿⣿⣿⣷⣄⣠⣾⠀⠀⣷⣄⣠⣾⣿⣿⣿⣿⣿⣿⠿⢋⣤⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣶⣬⡙⠻⠿⣿⣿⣿⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⣿⡿⠟⢋⣥⣶⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⠶⣤⣌⣉⣙⡛⠛⠛⠛⠛⠛⣋⣉⣩⣤⣶⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⠟⠁⠀⠀⠀⠉⣿⣿⣿⣿⣿⣿⣿⠏⠉⠀⠀⠈⠛⢿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
    echo " "
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    echo " "
    echo " "

  elif [[ ${splash_type} == negative ]]; then

    local SS="·"
    if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
      SS=""
    fi

    echo " "
    echo " "
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠉⠀⠀⠀⠀⠈⢉⣡⣤⠤⠶⠶⠶⠶⢤⣤⣈⡉⠋⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⣠⠶⠋⠉⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠉⠛⢶⣄⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⠛⠿⢿⡟⢁⡶⠉⠀⠀⠀⠀⠀⠀⠘⣿⣷⣿⣿⣾⡿⠃⠀⠀⠀⠀⠀⠀⠉⢶⡈⢿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠶⣿⣦⡀⣿⣿⣀⣴⣿⣦⠴⠒⠒⠒⠒⠦⢤⣌⣶⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣄⠀⠀⢠⠋⣶⣤⡀⢻⣿⠀⣿⡇⠀⣤⣄⠉⠻⣿⣿⠛⢁⠋⠀⠀⣶⣶⠀⣿⡆⢀⣤⠀⠀⣰⠁⠀⠀⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⡿⢠⠃⠀⠀⠉⣻⣿⣿⣤⣿⣿⠀⣿⠛⠿⣿⣿⣿⣿⣿⢸⣿⠀⣿⣟⣤⣿⣿⣟⠉⠀⢠⠻⡀⣴⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⡿⠀⡟⠀⠀⠈⠟⠋⠁⣤⣿⣿⣿⣶⣿⠂⠀⠀⣿⣿⠀⣿⢸⣿⣶⣿⣿⣿⣄⠈⠙⠁⢀⠋⠀⣿⠈⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⠀⠀⠀⢰⠁⠀⠀⠀⠀⠹⠟⠉⣀⣴⣾⡿⠛⠿⣿⣦⣿⣿⣿⣿⠟⠛⢿⣷⣤⡀⠉⠋⠀⣠⠋⠀⠀⢸⠀⠀⠀⠉⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "${SS}··•· ${title} ··•••" "${title_formatting}" "·" "${fill_t}" "${fill_t}"
    n2st::echo_centering_str "⣿⣿⣿⣿⠀⠀⠀⢸⠀⠀⠀⠀⠀⢀⡀⠈⠻⣿⣶⣄⠀⣀⣶⣿⣿⣿⣿⣦⣀⠀⣹⣦⣭⣥⣤⢖⠋⠀⠀⠀⠀⢸⠀⠀⠀⢸⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣷⣶⣤⠀⡇⠀⠀⠀⡀⠉⠛⣿⣷⣦⣴⣿⣿⠛⠁⠀⣿⣿⠀⠉⢻⣿⣿⣤⣴⣾⡿⠛⠉⣀⠀⠀⠀⢸⠀⢀⣠⣼⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⡆⢻⠀⠀⠈⠛⢿⣿⣾⣿⣿⣿⠀⣿⠀⣀⣴⣿⣿⣦⡀⢸⣿⠀⣿⡿⣿⣶⣿⠿⠛⠀⠀⠀⡟⣸⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⠟⠀⠀⢷⠀⣶⣿⠟⣻⣿⠀⣿⡏⠀⣿⡿⠛⢁⣿⣿⠉⠛⣿⣿⠀⣿⣿⠀⣿⡟⠿⣿⣶⠀⡿⠀⠙⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠻⡀⠀⠀⠛⠛⠀⠉⠁⠀⣀⣶⣿⠟⣿⣿⠿⣿⣦⡀⠀⠉⠉⠀⠛⠃⠀⠀⢠⠟⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣦⣀⣀⣤⡈⢷⡀⠀⠀⠀⠀⠀⠀⠀⠁⣠⣾⣿⣿⣶⣄⠉⠀⠀⠀⠀⠀⠀⠀⢀⡾⢁⡀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠈⠓⣤⠀⠀⠀⠀⠀⠈⠋⠀⣿⣿⠀⠛⠀⠀⠀⠀⠀⢀⣤⠛⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠉⠓⢦⣤⣀⡀⠀⠉⠉⠀⢀⣀⣤⡴⠚⠉⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⠀⣴⣿⣿⣶⣆⠀⠀⠀⠀⠀⠀⣶⣶⣿⣶⡀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣀⣀⣀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    n2st::echo_centering_str "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿" "${snow_formatting}" "⣿"
    echo " "
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " " "${fill_u}" "${fill_u}"
    echo " "
    echo " "

  else
    MSG_ERROR_FORMAT="\033[1;31m"
    MSG_END_FORMAT="\033[0m"
    echo -e "${MSG_ERROR_FORMAT}splash_type \"${splash_type}\" not implemented! ${MSG_END_FORMAT}" 1>&2
  fi

}

# ====legacy API support===========================================================================
function echo_centering_str() {
  n2st::echo_centering_str "$@"
}

function snow_splash() {
  n2st::snow_splash "$@"
}

function norlab_splash() {
  n2st::norlab_splash "$@"
}
