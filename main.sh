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
role=${1:-create_users}

if [[ "${debug_level}" -eq 0 ]]; then output="/dev/null"; else output=">${logdir}/error.log"; fi


function dump_event(){
  echo "[Error] There is some error with error code ${?}"
  exit 1
}

function usage(){
echo "Please use as $0 user1 user2 user3 ..."
}

function clone_repo(){
  echo "**** Cloning the repo ${clone_url} in the ${branch_name} branch "
  git clone -b ${branch_name} ${clone_url} ${clone_path} 2>${output}
}

function required_directories(){
  $(umask 77 && mkdir -p ${clone_path} && mkdir -p ${logdir} 2>${output}) || dump_event 
}



# installing ansible 
echo "**** Installing ansible"
if [[ "${os_version}" -eq "Ubuntu" ]]; then apt install ansible jq -y 2>${output} >/dev/null; else yum install ansible jq -y 2>${output} >/dev/null; fi

# exit from usages
if [[ "${#}" -lt 1 ]]; then usage && exit 1; fi

# set the defualt permissions
required_directories

#cloning github repo
clone_repo

# overwrring defaul variables
default_variable_file="${clone_path}/ansible/roles/${roles}/defaults/main.yml"
echo "users: " >${default_variable_file}
for name in "${@}"
do
cat << EOF >> ${default_variable_file}
  - { name: ${name}, password: ${name}, admin: true}
EOF
done

# run the ansible playbook

echo "**** Running Ansible playbook"
ansible-playbook ${clone_path}/ansible/create_user.yml -i ${server}, -c ${connection} -e "@${clone_path}/ansible/vars.yml"
if [[ "${?}" -eq 0 ]]; then echo "**** Succesfully created ${#} users - ${@}" ; else "****  There might be an issue" && exit 1; fi

echo "**** Deleting temprary files"
#rm -rf ${clone_path}
