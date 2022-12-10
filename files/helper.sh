
os_family=$(awk '/^ID=/' /etc/*-release | sed 's/ID=//' | tr '[:upper:]' '[:lower:]')
if [[ ${os_family} -eq 'ubuntu' ]]; then package_menager=apt; else package_menager=yum; fi
if [[ "${debug_level}" -eq 0 ]]; then output="/dev/null"; else output=">${logdir}/error.log"; fi
