#!/bin/bash
# Build a specific group of modules for CI.
# Usage: ci_build_group.sh <target_group>
#
# Reads build-groups.yml to resolve the group name to a module list, including
# the modules of the groups it depends on, then calls ansible.sh for them.

set -e

TARGET_GROUP="$1"

# When run from Dockerfile.ci, the script is copied to /tmp but WORKDIR
# is the ibek-support directory. When run locally, fall back to deriving
# the repo root from the script's own location.
if [ -f "$(pwd)/build-groups.yml" ]; then
    REPO_ROOT="$(pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
fi

if [ -n "$TARGET_GROUP" ]; then
    echo "=== Building target group: $TARGET_GROUP ==="
    modules=$(python3 "${REPO_ROOT}/_scripts/build_matrix.py" --modules "$TARGET_GROUP")
    if [ -n "$modules" ]; then
        echo "=== Building modules: $modules ==="
        ansible.sh "$modules" -e skip_clean=true
    fi
fi

echo "=== Group build complete ==="
