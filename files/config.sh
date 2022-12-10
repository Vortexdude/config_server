# default_variable_file="${clone_path}/ansible/roles/${role}/defaults/main.yml"

# create_directories 
role=$1
default_variable_file="${clone_path}/ansible/roles/${role}/files/main.sh"

echo "password_file_path: ${clone_path}" >${default_variable_file} 
echo "users: " >>${default_variable_file}
for name in "${@}"
do
cat << EOF >> ${default_variable_file}
  - { name: ${name}, password: ${name}, admin: true}
EOF
done


dump_event "Info" "Running Ansible playbook"
ansible-playbook ${clone_path}/ansible/${role}.yml -i ${server}, -c ${connection} 
[ "${?}" -eq 0 ] && users="${@}" && dump_event "Info" "Succesfully created ${#} users - ${users}" 

cat ${clone_path}/password.txt || dump_event "Warning" "Passsword File doesn't exists"