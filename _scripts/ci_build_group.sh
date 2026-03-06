#!/bin/bash
# Build a specific group of modules for CI.
# Usage: ci_build_group.sh <dep_groups> <target_group>
#
# Reads build-groups.yml to resolve group names to module lists,
# then calls ansible.sh for each group in order.

set -e

DEP_GROUPS="$1"
TARGET_GROUP="$2"

# When run from Dockerfile.ci, the script is copied to /tmp but WORKDIR
# is the ibek-support directory. When run locally, fall back to deriving
# the repo root from the script's own location.
if [ -f "$(pwd)/build-groups.yml" ]; then
    REPO_ROOT="$(pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
fi

# Extract module list for a given group name from build-groups.yml
get_group_modules() {
    local group_name="$1"
    python3 -c "
import yaml, sys
with open('${REPO_ROOT}/build-groups.yml') as f:
    data = yaml.safe_load(f)
groups = data.get('groups', {})
if '${group_name}' not in groups:
    print('ERROR: group ${group_name} not found', file=sys.stderr)
    sys.exit(1)
modules = groups['${group_name}'].get('modules', [])
print(','.join(modules))
"
}

# Build a comma-separated list of modules
build_modules() {
    local modules="$1"
    if [ -n "$modules" ]; then
        echo "=== Building modules: $modules ==="
        ansible.sh "$modules" -e skip_clean=true
    fi
}

# Build dependency groups first
if [ -n "$DEP_GROUPS" ]; then
    IFS=',' read -ra DEPS <<< "$DEP_GROUPS"
    for dep in "${DEPS[@]}"; do
        dep=$(echo "$dep" | xargs)  # trim whitespace
        echo "=== Building dependency group: $dep ==="
        modules=$(get_group_modules "$dep")
        build_modules "$modules"
    done
fi

# Build the target group
if [ -n "$TARGET_GROUP" ]; then
    if [ "$TARGET_GROUP" = "uncategorized" ]; then
        # Build everything not already built (catches new modules)
        echo "=== Building uncategorized (all remaining) modules ==="
        ansible.sh all -e from_dockerfile=false -e skip_clean=true
    else
        echo "=== Building target group: $TARGET_GROUP ==="
        modules=$(get_group_modules "$TARGET_GROUP")
        build_modules "$modules"
    fi
fi

echo "=== Group build complete ==="
