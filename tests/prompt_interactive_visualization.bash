#!/bin/bash

N2ST_ROOT="$( git rev-parse --show-toplevel )"
cd "${N2ST_ROOT}" || exit 1
source import_norlab_shell_script_tools_lib.bash

n2st::norlab_splash "The title" "https://the_url"

n2st::print_formated_script_header "$(basename "$0")" "${MSG_LINE_CHAR_BUILDER_LVL1}"

echo -e "
Terminal styles

  ${MSG_EMPH_FORMAT}MSG_EMPH_FORMAT${MSG_END_FORMAT}
  ${MSG_HIGHLIGHT_FORMAT}MSG_HIGHLIGHT_FORMAT${MSG_END_FORMAT}
  ${MSG_DIMMED_FORMAT}MSG_DIMMED_FORMAT${MSG_END_FORMAT}
  ${MSG_BASE_FORMAT}MSG_BASE_FORMAT${MSG_END_FORMAT}
  ${MSG_ERROR_FORMAT}MSG_ERROR_FORMAT${MSG_END_FORMAT}
  ${MSG_DONE_FORMAT}MSG_DONE_FORMAT${MSG_END_FORMAT}
  ${MSG_WARNING_FORMAT}MSG_WARNING_FORMAT${MSG_END_FORMAT}
"

echo -e "Example

${MSG_EMPH_FORMAT}Lorem ipsum dolor sit amet${MSG_END_FORMAT}, consectetur adipiscing elit. Nam in egestas magna, vel molestie mauris. Sed vehicula felis at felis posuere efficitur quis sit amet arcu. ${MSG_DIMMED_FORMAT}Proin egestas urna vulputate lorem pharetra, in posuere ipsum posuere.${MSG_END_FORMAT} Fusce condimentum mi, ${MSG_HIGHLIGHT_FORMAT}non euismod${MSG_END_FORMAT} quam fermentumet urna aliquam.
"

n2st::draw_horizontal_line_across_the_terminal_window "."
echo -e "
n2st::print_msg functions
"

n2st::print_msg "The message"
n2st::print_msg_done "The message"
n2st::print_msg_warning "The message"
n2st::print_msg_awaiting_input "The message"
n2st::print_msg_error "The message"
echo

n2st::draw_horizontal_line_across_the_terminal_window "."
echo -e "
MSG_LINE_CHAR styles

  MSG_LINE_CHAR_BUILDER_LVL1: $MSG_LINE_CHAR_BUILDER_LVL1
  MSG_LINE_CHAR_BUILDER_LVL2: $MSG_LINE_CHAR_BUILDER_LVL2
  MSG_LINE_CHAR_INSTALLER: $MSG_LINE_CHAR_INSTALLER
  MSG_LINE_CHAR_UTIL: $MSG_LINE_CHAR_UTIL
  MSG_LINE_CHAR_TEST: $MSG_LINE_CHAR_TEST
"

n2st::draw_horizontal_line_across_the_terminal_window "$MSG_LINE_CHAR_BUILDER_LVL1"
n2st::draw_horizontal_line_across_the_terminal_window "$MSG_LINE_CHAR_BUILDER_LVL2"
n2st::draw_horizontal_line_across_the_terminal_window "$MSG_LINE_CHAR_INSTALLER"
n2st::draw_horizontal_line_across_the_terminal_window "$MSG_LINE_CHAR_UTIL"
n2st::draw_horizontal_line_across_the_terminal_window "$MSG_LINE_CHAR_TEST"


n2st::print_formated_script_footer "$(basename "$0")" "${MSG_LINE_CHAR_BUILDER_LVL1}"





