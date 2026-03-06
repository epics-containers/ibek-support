#!/bin/bash
# Build one or all module groups locally (inside the developer container).
#
# Usage:
#   local_build_groups.sh              # build all groups
#   local_build_groups.sh core         # build just the core group
#   local_build_groups.sh motor        # build core (dep) + motor
#   local_build_groups.sh --list       # list available groups
#
# This mirrors what CI does but runs directly in the devcontainer,
# without needing Docker.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="${SCRIPT_DIR}/ci_build_group.sh"

get_all_groups() {
    python3 -c "
import yaml
with open('${REPO_ROOT}/build-groups.yml') as f:
    data = yaml.safe_load(f)
for name, group in data['groups'].items():
    deps = ','.join(group.get('deps', []))
    print(f'{name}|{deps}|{group.get(\"desc\", \"\")}')
"
}

if [ "$1" = "--list" ]; then
    echo "Available build groups:"
    echo
    get_all_groups | while IFS='|' read -r name deps desc; do
        dep_info=""
        if [ -n "$deps" ]; then
            dep_info=" (deps: $deps)"
        fi
        echo "  $name$dep_info - $desc"
    done
    echo
    # Check for uncategorized modules
    python3 "${SCRIPT_DIR}/build_matrix.py" --check 2>&1 | grep -E "^ERROR|^Uncategorized" || true
    exit 0
fi

if [ -z "$1" ]; then
    echo "=== Building ALL groups ==="
    echo
    get_all_groups | while IFS='|' read -r name deps desc; do
        echo ">>> Group: $name ($desc)"
        bash "$BUILD_SCRIPT" "$deps" "$name"
        echo
    done
    echo "=== All groups built ==="
else
    GROUP="$1"
    # Look up deps for this group
    DEPS=$(python3 -c "
import yaml
with open('${REPO_ROOT}/build-groups.yml') as f:
    data = yaml.safe_load(f)
groups = data['groups']
if '${GROUP}' not in groups:
    print('ERROR', end='')
else:
    print(','.join(groups['${GROUP}'].get('deps', [])), end='')
")
    if [ "$DEPS" = "ERROR" ]; then
        echo "ERROR: group '$GROUP' not found in build-groups.yml"
        echo "Run '$0 --list' to see available groups."
        exit 1
    fi
    echo "=== Building group: $GROUP ==="
    bash "$BUILD_SCRIPT" "$DEPS" "$GROUP"
fi
