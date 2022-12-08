#!/bin/bash

debug_level=0
product_name=srelia
logdir=/var/log/${product_name}/
clone_path="/tmp/.${product_name}/cloned_repo"
clone_url="https://github.com/Vortexdude/${product_name}"
branch_name="main"
os_version=$(cat /etc/os-release | grep PRETTY_NAME | awk -F= '{print $2}' | tr -d '"' | awk '{print $1}')
server=localhost
connection=local
ignore_errors=true
role="${1:-create_users}"

if [[ "${debug_level}" -eq 0 ]]; then output="/dev/null"; else output=">${logdir}/error.log"; fi


function dump_event(){ 
  echo " [${1]}] ${2}" 
  [ ${ignore_errors} ] && status=0 || status=1
  exit ${status}
}

function usage(){
echo "Please use as $0 user1 user2 user3 ..."
}

function clone_repo(){
  echo "**** Cloning the repo ${clone_url} in the ${branch_name} branch "
  git clone -b ${branch_name} ${clone_url} ${clone_path}
}

function required_directories(){
  umask 77
  if [ -d ${clone_path} ]; then dump_event "Warning" "Directory Exist" && rm -rf ${clone_path} ${logdir}; else  mkdir -p ${clone_path} ${logdir}; fi
}

# installing ansible 
dump_event "Info" "Installing ansible"
if [[ "${os_version}" -eq "Ubuntu" ]]; then apt install ansible jq -y 2>${output} >/dev/null; else yum install ansible jq -y 2>${output} >/dev/null; fi

# exit from usages
if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi

# set the defualt permissions
required_directories

#cloning github repo
clone_repo && dump_event "Info" "Cloning the repo ${clone_url} in the ${branch_name} branch " || dump_event "Error" "Can't able to Clone the repo"

# overwrring defaul variables
default_variable_file="${clone_path}/ansible/roles/${role}/defaults/main.yml"
echo "users: " >${default_variable_file}
for name in "${@}"
do
cat << EOF >> ${default_variable_file}
  - { name: ${name}, password: ${name}, admin: true}
EOF
done

# run the ansible playbook
echo "**** Running Ansible playbook"
ansible-playbook ${clone_path}/ansible/${role}.yml -i ${server}, -c ${connection}"
if [[ "${?}" -eq 0 ]]; then echo "**** Succesfully created ${#} users - ${@}" ; else "****  There might be an issue" && exit 1; fi

echo "**** Deleting temprary files"
#rm -rf ${clone_path}
