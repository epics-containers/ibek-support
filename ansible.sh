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

this_dir=$(dirname $0)
cd $this_dir

path=${module_name}/${module_name}.yml

ansible-playbook \
    _ansible/support_playbook.yml \
    -i _ansible/hosts.yml \
    -e @${path} ${vers}

