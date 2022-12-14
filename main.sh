#!/bin/bash
# set -ex

# Exit status - 
# 1 usages
# 5 file not found

c="\033[0"
# Color variables
red="${c};31m"
green="${c};32m"
yellow="${c};33m"
# Clear the color after that
clear="${c}m"

#clone the repo
product_name=srelia
clone_path="/tmp/.${product_name}/cloned_repo"
clone_url="https://github.com/Vortexdude/${product_name}"
branch_name="new-feature"
logdir=/var/log/${product_name}/
debug_level=0
server=localhost
connection=local
ignore_errors=true
role=create_users

function usage(){
    echo "Please use as ${0} user1 user2 user3 ..." && exit 1
}

dump_event() { 
  rc="${3:-0}"
  if [[ "${1}" == "Error" ]]
  then 
    status="${red}${1}${clear}"
  elif [[ "${1}" == "Warning" ]]
  then 
    status="${yellow}${1}${clear}"
  else 
    status="${green}${1}${clear}"
  fi

  echo -e "[ ${status} ] ${2}\n" 
  if [[ "${rc}" -ne 0 ]]; then exit 1 ||  [ ${ignore_errors} ] ;fi
}

if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi

#Run script as sudo 
if [ "$EUID" -ne 0 ]; then dump_event "Error" "Please run script with root" 1 ; fi

umask 77
if [ -d ${clone_path} ]
then 
  dump_event "Warning" "Directory Exist" 
  rm -rf ${clone_path}
else  
  mkdir -p ${clone_path}
fi

dump_event "Info" "Cloning the repo ${clone_url} in the ${branch_name} branch "
git clone -b ${branch_name} ${clone_url} ${clone_path} 2>/dev/null || dump_event "Error" "Can't able to clone the Repo check the logs at ${log_dir}" 1

. ${clone_path}/files/all_functions.sh
. ${clone_path}/files/helper.sh

install_package "ansible"

. ${clone_path}/files/config.sh
# Deleting temprary files
[ -d ${clone_path} ] && dump_event "Info" "Deleting temprary files" && rm -rf ${clone_path} || dump_event "Error" "Permission denied"
