#!/usr/bin/env python3
"""
Generate a GitHub Actions build matrix from build-groups.yml.

Scans all *.install.yml files in ibek-support to discover modules,
then checks them against the groups defined in build-groups.yml.
Any module not assigned to a group is placed in an "uncategorized" group
so that new modules are always tested.

Usage:
    python _scripts/build_matrix.py              # print matrix JSON
    python _scripts/build_matrix.py --check      # exit 1 if uncategorized modules exist
    python _scripts/build_matrix.py --github      # output for GitHub Actions
"""

import argparse
import glob
import json
import os
import sys

import yaml

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD_GROUPS_FILE = os.path.join(REPO_ROOT, "build-groups.yml")


def discover_modules():
    """Find all modules that have a *.install.yml file."""
    pattern = os.path.join(REPO_ROOT, "*", "*.install.yml")
    modules = set()
    for path in glob.glob(pattern):
        # Module name is the parent directory name
        module = os.path.basename(os.path.dirname(path))
        # Skip internal ansible temp files
        if module.startswith("_"):
            continue
        modules.add(module)
    return modules


def load_groups():
    """Load build-groups.yml and return the groups dict."""
    with open(BUILD_GROUPS_FILE) as f:
        data = yaml.safe_load(f)
    return data.get("groups", {})


def build_matrix(check_mode=False):
    """Build the CI matrix, returning (matrix_dict, uncategorized_modules)."""
    all_modules = discover_modules()
    groups = load_groups()

    # Collect all modules assigned to groups
    assigned = set()
    for group_name, group in groups.items():
        for mod in group.get("modules", []):
            if mod in assigned:
                print(f"WARNING: module '{mod}' appears in multiple groups", file=sys.stderr)
            assigned.add(mod)

    # Modules not in any group
    uncategorized = sorted(all_modules - assigned)

    # Modules in groups but missing install.yml
    missing = sorted(assigned - all_modules)
    if missing:
        print(f"WARNING: modules in build-groups.yml but no install.yml found: {missing}", file=sys.stderr)

    # Build the matrix entries
    matrix_entries = []
    for group_name, group in groups.items():
        # Filter to only modules that actually exist
        modules = [m for m in group.get("modules", []) if m in all_modules]
        if not modules:
            continue
        matrix_entries.append({
            "group": group_name,
            "desc": group.get("desc", ""),
            "deps": group.get("deps", []),
            "modules": modules,
        })

    # Add uncategorized group if there are any
    if uncategorized:
        matrix_entries.append({
            "group": "uncategorized",
            "desc": "Auto-discovered modules not yet assigned to a group",
            "deps": ["core"],
            "modules": uncategorized,
        })

    return {"include": matrix_entries}, uncategorized


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="Exit 1 if uncategorized modules exist")
    parser.add_argument("--github", action="store_true",
                        help="Output matrix= line for GitHub Actions")
    parser.add_argument("--uncategorized", action="store_true",
                        help="Print comma-separated list of uncategorized modules")
    args = parser.parse_args()

    matrix, uncategorized = build_matrix(check_mode=args.check)

    if args.uncategorized:
        if uncategorized:
            print(",".join(uncategorized))
    elif args.github:
        print(f"matrix={json.dumps(matrix)}")
    else:
        print(json.dumps(matrix, indent=2))
        if uncategorized:
            print(f"\nUncategorized modules: {uncategorized}", file=sys.stderr)
            print("Add these to build-groups.yml to avoid this warning.", file=sys.stderr)

    if args.check and uncategorized:
        print(f"ERROR: {len(uncategorized)} uncategorized module(s): {uncategorized}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
