#!/bin/bash
# ToDo: unit-test
#
# Utility script to install docker related tools and execute basic configuration
#
# Requirement: This script must be sourced from directory 'utility_scripts'
#
# Usage:
#   $ cd <path/to/project>/norlab-shell-script-tools/src/utility_scripts
#   $ bash ./install_docker_tools.bash
#


# ....Pre-condition................................................................................................
if [[ "$(basename "$(pwd)")" != "utility_scripts" ]]; then
  echo -e "\n[\033[1;31mERROR\033[0m] 'install_docker_tools.bash' script must be sourced from the 'utility_scripts/'!\n Curent working directory is '$(pwd)'"
  echo '(press any key to exit)'
  read -nr 1
  exit 1
fi


## ....Load environment variables from file.........................................................................
#set -o allexport
#source ../../.env.norlab_2st
#source ../../.env.project
#set +o allexport

# ....Load helper function.........................................................................................
TMP_CWD=$(pwd)
cd ../function_library || exit
source ./prompt_utilities.bash
source ./docker_utilities.bash
cd "${TMP_CWD}"

# ====Begin========================================================================================================
print_formated_script_header 'install_docker_tools.bash'

# .................................................................................................................
echo
print_msg "Install utilities"
echo

sudo apt-get update &&
  sudo apt-get upgrade --assume-yes &&
  sudo apt-get install --assume-yes \
    ca-certificates \
    curl \
    lsb-release \
    gnupg \
    apt-utils &&
  sudo rm -rf /var/lib/apt/lists/*

# .................................................................................................................
echo
print_msg "Install Docker tools"

# . . Add Docker’s official GPG key:. . . . . . . . . . . . . . . . . . . . . . . . . . .
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# . . set up the docker repository:. . . . . . . . . . . . . . . . . . . . . . . . . . .
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null


sudo apt-get update &&
  sudo apt-get upgrade &&
  sudo apt-get install --assume-yes \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# .................................................................................................................
echo
print_msg "Configure docker"
echo

add_user_to_the_docker_group "$(whoami)"

print_formated_script_footer 'install_docker_tools.bash'
# ====Teardown=====================================================================================================
cd "${TMP_CWD}"  || exit