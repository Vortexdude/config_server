# default_variable_file="${clone_path}/ansible/roles/${role}/defaults/main.yml"

playbook_path="${clone_path}/ansible/playbook.yml"
var_file_path="${clone_path}/ansible/vars.yml"
cat <<EOF >> ${playbook_path}
- hosts: all
  become: true
  roles:
EOF

for role in ${roles}
do
cat <<EOF >> ${playbook_path}
    - { name: $role }
EOF
done

echo "users: " >> ${var_file_path}
for name in "${@}"
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
  users="${@}"
  dump_event "Info" "Succesfully created ${#} users - ${users}" 
fi
