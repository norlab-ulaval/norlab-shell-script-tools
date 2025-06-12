#!/bin/bash
# =================================================================================================
# Terminal splash related functions
#
# Requirement:
#   This script must be executed from project root 'NorLab-TeamCity-Server-infrastructure'
#
# Usage:
#   $ source function_library/terminal_splash.bash
#
# =================================================================================================

# Note: enable only for debugging
#set -e
#set -v

# =================================================================================================
# Dynamic printf centering tool. Centering based on the terminal screen width at runtime.
#
# Usage:
#   $ source function_library/terminal_splash.bash
#   $ n2st::echo_centering_str <theString> <theStyle> <thePadCharacter> [<fill_left>] [<fill_right>]
#
# Example:
#   $ n2st::echo_centering_str "···•· ${title} ··•••" "\033[1;37m" "\033[0m·"
#
# Note:
#   Since console printing formating related error as no consequences on program main logic
#   execution, the function manage those gracefully by simply continuing execution without
#   printing warning and error to console.
#
# Globals:
#   none
# Arguments:
#   <theString>           The string to center
#   <theStyle>            The style appended at the begining of the line (set to ' ' to mute style)
#   <thePadCharacter>     The padding character to use
# Globals:
#   read LC_CTYPE
#   read LC_ALL
#   read BATS_TEST_FILENAME
#   read TEAMCITY_VERSION
#   read IS_TEAMCITY_RUN
#   read TERM
#   read COLUMNS
# Outputs:
#   Output the line to STDOUT
#   The stderr output is muted in case of console print related problem (warning or error)
# Returns:
#   0 on success
# =================================================================================================
function n2st::echo_centering_str() {
  local show_debug=false

  # (NICE TO HAVE) ToDo:
  #     - var TERM should be setup in Dockerfile.dependencies.
  #     - print a warning message if TERM is not set

  # ....Positional arguments.......................................................................
  local text_pre=${1:?'Missing a mandatory parameter error'}
  local style="${2:?'Missing a mandatory parameter error'}"
  local pad_char="${3:?'Missing a mandatory parameter error'}"
  local fill_left="${4:-""}"
  local fill_right="${5:-""}"

  # ....Pre-check and set default locale...........................................................
  # Save original locale settings
  local original_lc_ctype="${LC_CTYPE:-}"
  local original_lc_all="${LC_ALL:-}"

  # Try to use a UTF-8 locale for consistent character handling
  if locale -a 2>/dev/null | grep -q "C.UTF-8"; then
      export LC_ALL="" LC_CTYPE="C.UTF-8"
  elif locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
      export LC_ALL="" LC_CTYPE="en_US.UTF-8"
  else
      export LC_ALL="" LC_CTYPE="C"
  fi

  # ....Get terminal width.........................................................................
  local terminal_min_witdh_fallback=80
  local term_width

  if [[ -n "$COLUMNS" ]]; then
      term_width="$COLUMNS"
  elif command -v tput >/dev/null 2>&1; then
      if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
          term_width=$(tput -T xterm-256color cols 2>/dev/null) || term_width="$terminal_min_witdh_fallback"
      else
          term_width=$(tput cols 2>/dev/null) || term_width="$terminal_min_witdh_fallback"
      fi
  else
      term_width="$terminal_min_witdh_fallback"  # Default fallback
  fi

  if [[ -n "${BATS_TEST_FILENAME}" ]]; then
    term_width=$(( term_width - 9))
  fi

  # ....Padding....................................................................................
  # Compute padding value
  local text
  local text_width
  local pad_char_len
  printf -v text -- "%b" "${text_pre}" 2>/dev/null
  [[ $? -ne 0 ]] && text=$text_pre  # Fallback
  text_width=${#text}
  pad_char_len=${#pad_char}

  local total_padding=$(( term_width - $((text_width / pad_char_len)) )) 2>/dev/null
  local side_padding=$((total_padding / 2)) 2>/dev/null

  # Generate padding
  # Note: this a more robust method than using the seq command when handling unicode char
  local pad=""
  local i=0
  while ((i < side_padding)); do
      pad="${pad}${pad_char}"
      ((i++))
  done

  # ....Formating..................................................................................
  if [[ "${style}" == " " ]]; then
    style=""
  fi
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    style=""
    local style_off=""
  else
    local style_off="\033[0m"
  fi

  # Note: adding `2>/dev/null` at the end is a quick-hack. Will need a more robust solution.
  #       ref task N2ST-2 fix: splash LC_TYPE related error

  # Alternative implementation
  #echo -n -e  "${style}" 2>/dev/null
  #LC_CTYPE="${LC_CTYPE}" echo -e "${fill_left}${pad}${text}${pad}${fill_right}" 2>/dev/null
  #echo -n -e  "${style_off}" 2>/dev/null

  {
    printf "%b" "${style}"
    printf -- "%b%s%b%s%b" "${fill_left}" "${pad}" "${text}" "${pad}" "${fill_right}"
    printf "%b\n" "${style_off}"
  } 2>/dev/null

  # ....Debug utils................................................................................
  if [[ ${show_debug} == true ]]; then
    echo -e "term_width: ${term_width}"
    echo -e "text_width: ${text_width}"
    echo -e "pad_char_len: ${pad_char_len}"
    echo -e "total_padding: ${total_padding}"
    echo -e "side_padding: ${side_padding}"
  fi

  # ....Teardown...................................................................................
  # Restore original locale settings
  export LC_CTYPE="${original_lc_ctype}"
  export LC_ALL="${original_lc_all}"

  # The return value is only relevant for testing purposes.
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

  # Formatting
  #   - 1=Bold/bright
  #   - 2=Dim
  #   - 4=underline
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    local title_formatting=" "
    local snow_formatting=" "
    local url_formatting=" "
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
  n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·"
  n2st::echo_centering_str "⢠⣶⣤⣄⣀⣤⣶⣿⢿⣿⢿⣿⣶⣄⣀⣤⣤⣶⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⣨⣿⣿⣿⡟⠁⠀⢸⣿⠀⠀⠉⣿⣿⣿⣯⣀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠈⠛⠁⣿⣿⢀⠀⣠⣿⣿⣷⡀⠀⠈⣿⣧⠉⠛⢀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⣾⡿⢻⣿⠙⣿⡷⠀⠈⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  n2st::echo_centering_str "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "${snow_formatting}" "⠀"
  echo " "
  n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " "
  n2st::echo_centering_str "${optional_url}" "${url_formatting}" " "
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


  # Formatting
  #   - 1=Bold/bright
  #   - 2=Dim
  #   - 4=underline
  if [[ ${TEAMCITY_VERSION} ]] || [[ ${IS_TEAMCITY_RUN} == true ]] ; then
    local title_formatting=" "
    local snow_formatting=" "
    local url_formatting=" "
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
    n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·"
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
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " "
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " "
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
    n2st::echo_centering_str "···•· ${title} ··•••" "${title_formatting}" "·"
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
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " "
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " "
    echo " "
    echo " "

  elif [[ ${splash_type} == negative ]]; then

    local SS="⠐"
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
    n2st::echo_centering_str "${SS}··•· ${title} ··•••" "${title_formatting}" "·"
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
    n2st::echo_centering_str "https://norlab.ulaval.ca" "${url_formatting}" " "
    n2st::echo_centering_str "${optional_url}" "${url_formatting}" " "
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
