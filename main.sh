#!/bin/bash
# set -ex

# Exit status - 
# 1 usages
# 5 file not found


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

dump_event() { echo "[${1}] ${2}" && [ ${ignore_errors} ] || exit 1; }

umask 77
if [ -d ${clone_path} ]
then 
  dump_event "Warning" "Directory Exist" 
  rm -rf ${clone_path}
else  
  mkdir -p ${clone_path}
fi

dump_event "Info" "Cloning the repo ${clone_url} in the ${branch_name} branch "
git clone -b ${branch_name} ${clone_url} ${clone_path} 2>/dev/null || dump_event "Error" "Can't able to clone the Repo check the logs at ${log_dir}"

. ${clone_path}/files/all_functions.sh
if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi
. ${clone_path}/files/helper.sh

install_package "ansible"

. ${clone_path}/files/config.sh
# Deleting temprary files
[ -d ${clone_path} ] && dump_event "Info" "Deleting temprary files" && rm -rf ${clone_path} || dump_event "Error" "Permission denied"
