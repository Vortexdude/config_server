
function get_bin_path(){
  path=$(which ${1}) 2>/dev/null
  if [[ "${?}" -ne 0 ]]
  then dump_event "Info" "Installing ${1}"
  ${package_menager} install ${1} -y 2>${output} >/dev/null || dump_event "Error" "Cant able to locate packages in repository"
  path=$(which ${1}) 2>/dev/null
  fi
}

function install_package(){
    dump_event "Info" "Installing ${1}"
    ${package_menager} install ${1} -y 2>${output} >/dev/null || dump_event "Error" "Cant able to locate packages in repository"
    dump_event "Success" "${1} Installed"
}

function create_directories(){
  for dir in "${@}"
  do
    mkdir -p ${clone_path}/${dir}
  done
}