#!/bin/bash

module_name=$1
module_version=$2

if [[ -z $module_name ]]; then
    echo "Usage: $0 <module_name> [<module_version>]"
    exit 1
fi

if [[ -n $module_version ]]; then
    vers="-e version=${module_version}"
fi

if [[ $ANSIBLE_TAGS ]]; then
    tags=" --tags ${ANSIBLE_TAGS}"
    echo "limiting ansible run to tags: ${ANSIBLE_TAGS}"
fi

# modules are relative to this dir (ibek-support or ibek-support-dls etc.)
this_dir=$(dirname $0)
cd $this_dir

# ansible playbook and roles come from the ibek-support repo always
ansible_dir=/epics/generic-source/ibek-support/_ansible
vars=

# separate playbooks for all modules, a single support module or the
if [[ ${module_name} == "all" ]] ; then
    pb=${ansible_dir}/all_playbook.yml
elif [[ ${module_name} == "ioc" ]] ; then
    pb=${ansible_dir}/ioc_playbook.yml
else
    pb=${ansible_dir}/support_playbook.yml
    # load vars from the module yaml file
    vars="-e @${module_name}/${module_name}.yml"
fi

set -x
ansible-playbook ${pb} -i ${ansible_dir}/hosts.yml ${vars} ${vers} ${tags}
