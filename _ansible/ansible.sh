#!/bin/bash

# launch script for the ansible playbooks

module_name=$1
module_version=$2

if [[ -z $module_name ]]; then
    echo "Usage: $0 <module_name> [<module_version>]"
    echo "  where <module_name> the support module to install, or 'ioc' or 'all'"
    echo
    echo "  launches an ansible playbook to configure and install the module[s]"
    exit 1
fi

if [[ -n $module_version ]]; then
    vers="-e version=${module_version}"
fi

if [[ $ANSIBLE_TAGS ]]; then
    tags=" --tags ${ANSIBLE_TAGS}"
    echo "limiting ansible run to tags: ${ANSIBLE_TAGS}"
fi

if [[ $ANSIBLE_ARGS ]]; then
    args="${ANSIBLE_ARGS}"
fi

# ansible playbook and roles come from the ibek-support repo always
ansible_dir=$(realpath $(dirname ${0}))
pb=${ansible_dir}/playbook.yml

vars=" -e module_name=${module_name}"

set -x
ansible-playbook ${pb} -i ${ansible_dir}/hosts.yml ${vars} ${vers} ${tags} ${args}
