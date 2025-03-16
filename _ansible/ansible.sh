#!/bin/bash

# launch script for the ansible playbooks

# allow -v VERSION to override the version of the module to install
# remaining arguments are passed to the ansible-playbook command
while getopts 'v:h' opt; do
  case "$opt" in
    v) module_version="$OPTARG" ;;
    h) ;;
  esac
done

module_name=${@:$OPTIND:1}
args=${@:$OPTIND+1:20}

if [[ -z $module_name ]]; then
    echo "Usage: $(basename $0) module/all/ioc [-v version] [-h] [arguments]"
    echo "  where:"
    echo "    module is support module to install or 'ioc' or 'all'"
    echo "    version is an optional version override for the module"
    echo "    arguments are passed to the ansible-playbook command"
    exit 1
fi

if [[ -n $module_version ]]; then
    vers="-e version=${module_version}"
fi

# ansible playbook and roles come from the ibek-support repo always
ansible_dir=$(realpath $(dirname ${0}))
pb=${ansible_dir}/playbook.yml

vars=" -e module_name=${module_name}"

set -x
ansible-playbook ${pb} -i ${ansible_dir}/hosts.yml ${vars} ${vers} ${args}
