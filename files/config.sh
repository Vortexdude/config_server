# default_variable_file="${clone_path}/ansible/roles/${role}/defaults/main.yml"

role_variable_file="${clone_path}/ansible/roles/*/files/main.sh"
playbook_path="${clone_path}/ansible/playbook.yml"
var_file_path="${clone_path}/ansible/vars.yml"
number_of_roles=$(ls -p ${clone_path}/ansible/roles/ | grep /$ | wc -l)

# source the variable type file
source ${role_variable_file}

# get the variable
# predefined_variable="type_of_[[:alpha:]]+"

# [[ ${username} =~ ${type_of_username} ]] && dump_event "Info" "Variable type is correct" || dump_event "Error" "Dont expect the other type of value" 1
read -p " Enter the Users : " users

for variable_type in "${users}"
do
  [[ ${variable_type} =~ ${type_of_username} ]] && dump_event "Info" "Variable type is correct" || dump_event "Error" "Dont expect the other type of value" 1
done

cat <<EOF >> ${playbook_path}
- hosts: all
  become: true
  roles:
EOF

for role in $roles
do
cat <<EOF >> ${playbook_path}
    - { name: $role }
EOF
done

echo "users: " >> ${var_file_path}
for name in "${users}"
do
cat <<EOF >> ${var_file_path}
  - { name: ${name}, password: ${name}, admin: true}
EOF
done

dump_event "Info" "Running Ansible playbook"
ansible-playbook ${playbook_path} -i ${server}, -c ${connection} --extra-vars "@${var_file_path}"
if [ "${?}" -ne 0 ];
then
  dump_event "Error" "There is an issue with the playbook" $?
else
  users="${users}"
  dump_event "Info" "Succesfully created ${#} users - ${users}" 
fi
