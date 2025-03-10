#!/bin/bash

# To use this launch script, symlink in into the root of ibek-support
# or ibek-support-dls etc.

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

# module are relative to this dir (ibek-support or ibek-support-dls etc.)
this_dir=$(dirname $0)
cd $this_dir

# ansible playbook and roles come from the ibek-support repo always
ansible_dir=/epics/generic-source/ibek-support/_ansible

path=${module_name}/${module_name}.yml

ansible-playbook \
    ${ansible_dir}/support_playbook.yml \
    -i ${ansible_dir}/hosts.yml \
    -e @${path} ${vers} \
    ${tags}

