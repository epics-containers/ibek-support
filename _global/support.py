"""
Provide a basic CLI for managing a set of EPICS support modules
"""

import os
import re
import subprocess
from pathlib import Path
from typing import Optional
from jinja2 import Template

import typer

# note requirement for enviroment variable EPICS_BASE
EPICS_BASE = Path(str(os.getenv("EPICS_BASE")))
EPICS_ROOT = Path(str(os.getenv("EPICS_ROOT")))

# all support modules will reside under this directory
SUPPORT = Path(str(os.getenv("SUPPORT")))
# the global RELEASE file which lists all support modules
RELEASE = Path(f"{SUPPORT}/configure/RELEASE")
# a bash script to export the macros defined in RELEASE as environment vars
RELEASE_SH = Path(f"{SUPPORT}/configure/RELEASE.shell")
# global MODULES file used to determine order of build
MODULES = Path(f"{SUPPORT}/configure/MODULES")
# Folder containing Makefile.jinja
MAKE_FOLDER = Path(str(os.getenv("IOC"))) / "iocApp/src"
# Folder containing ibek support scripts
SCRIPTS_FOLDER = Path("/workspace/ibek-support")

# find macro name and macro value in a RELEASE file
PARSE_MACROS = re.compile(r"^([A-Z_a-z0-9]*)\s*=\s*(.*)$", flags=re.M)
# turn RELEASE macros into bash macros
SHELLIFY_FIND = re.compile(r"\$\(([^\)]*)\)")
SHELLIFY_REPLACE = r"${\1}"


cli = typer.Typer()


@cli.command()
def fix_release(
    name: str = typer.Argument(..., help="the name of the support module"),
    macro: Optional[str] = typer.Argument(None, help="Macro name for the module"),
    path: Optional[Path] = typer.Argument(None, help="The path to the support module"),
):
    """
    prepare the configure RELEASE files to build a support module
    inside an epics-containers build

    arguments:
        name:  name of the support module
        macro: name of the macro to use in RELEASE, default to name.upper()
        path:  path to the support module, default to EPICS_ROOT/support/<name>
    """
    if macro is None:
        macro = name.upper()
    if path is None:
        path = EPICS_ROOT / "support" / name

    # add or replace our macro pointing to our module path in the RELEASE file
    with RELEASE.open("r") as stream:
        lines = stream.readlines()
    outlines = []
    replaced = False
    for line in lines:
        if line.startswith(f"{macro}="):
            outlines.append(f"{macro}={path}\n")
            replaced = True
        else:
            outlines.append(line)
    if not replaced:
        outlines.append(f"{macro}={path}\n")

    with RELEASE.open("w") as stream:
        stream.writelines(outlines)

    do_dependencies()


def do_run(command: str, errors=True, cwd=None):
    print(command)
    # use bash for enviroment variable expansion
    p = subprocess.run(command, shell=True, cwd=cwd)
    if p.returncode != 0 and errors:
        raise RuntimeError("subprocess failed.")


def do_dependencies():
    # parse the global release file
    versions = {}
    text = RELEASE.read_text()
    for match in PARSE_MACROS.findall(text):
        versions[match[0]] = match[1]

    # find all the configure folders
    configure_folders = SUPPORT.glob("*/configure")
    for configure in configure_folders:
        release_files = configure.glob("RELEASE*")
        # iterate over all release files
        for rel in release_files:
            orig_text = text = rel.read_text()
            # find any occurrences of global macros and replace with global value
            for macro, val in versions.items():
                replace = re.compile(f"^({macro}*\\s*=[ \t]*)(.*)$", flags=re.M)
                text = replace.sub(r"\1" + val, text)
            if orig_text != text:
                print(f"updating dependencies in {rel}")
                rel.write_text(text)

    # generate the MODULES file for inclusion into the root Makefile
    # it simply defines a variable to hold each of the support module
    # directories in the order they are presented in RELEASE, except that
    # the IOC is always listed last, if present.
    s = str(SUPPORT)
    print(s, versions.values())
    paths = [path[len(s) + 1 :] for path in versions.values() if path.startswith(s)]
    if "IOC" in versions:
        paths.append(versions["IOC"])
    mod_list = f'MODULES := {" ".join(paths)}\n'
    MODULES.write_text(mod_list)

    # generate RELEASE.sh file for inclusion into the ioc launch shell script.
    # This adds all module paths to the environment and also adds their db
    # folders to the database search path env variable EPICS_DB_INCLUDE_PATH
    release_sh = []
    for module, path in versions.items():
        release_sh.append(f'export {module}="{path}"')

    db_paths = [f"{path}/db" for path in versions.values() if path.startswith(s)]
    db_path_list = ":".join(db_paths)
    release_sh.append(f'export EPICS_DB_INCLUDE_PATH="{db_path_list}"')

    shell_text = "\n".join(release_sh) + "\n"
    shell_text = SHELLIFY_FIND.sub(SHELLIFY_REPLACE, shell_text)
    RELEASE_SH.write_text(shell_text)


@cli.command()
def dependencies():
    """
    update the dependencies of all support modules so that they are all
    consistent within EPICS_ROOT/support
    """
    do_dependencies()


@cli.command()
def makefile():
    """
    get the dbd and lib files from all support modules and generate
    iocApp/src/Makefile from iocApp/src/Makefile.jinja
    """

    # use modules file to get a list of all support module folders
    # in the order of build (and hence dependency)
    modules = MODULES.read_text().split()[2:]
    # remove the IOC folder from the list
    if "IOC" in modules:
        modules.remove("IOC")

    # get all the dbd and lib files from each support module
    dbds = []
    libs = []
    for module in modules:
        folder = SCRIPTS_FOLDER / module
        dbd_file = folder / "dbd"
        if dbd_file.exists():
            dbds.extend(dbd_file.read_text().split())
        lib_file = folder / "lib"
        if lib_file.exists():
            libs.extend(lib_file.read_text().split())

    # generate the Makefile from the template
    template = Template((MAKE_FOLDER / "Makefile.jinja").read_text())
    # libraries are listed in reverse order of dependency
    libs.reverse()
    text = template.render(dbds=dbds, libs=libs)

    with (MAKE_FOLDER / "Makefile").open("w") as stream:
        stream.write(text)


if __name__ == "__main__":
    cli()
    # for quick debugging of e.g. dependencies function change to:
    # cli(["dependencies"])
