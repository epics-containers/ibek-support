#!/usr/bin/env python
"""
A Pydantic model for the support install variables. Describes the variables
that can be supplied to the ansible role support described in

Execute this python script to generate a new schema file.
"""

import json
from pathlib import Path
from typing import Sequence

from pydantic import BaseModel, ConfigDict, Field


class StrictModel(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        use_enum_values=True,
    )


class SupportVariables(StrictModel):
    # nested classes ##########################################################

    class DownloadExtras(StrictModel):
        url: str
        dest: str

    class CommentOut(StrictModel):
        path: str
        regexp: str
        when: str = Field(default="")

    class PatchLines(StrictModel):
        path: str
        regexp: str
        line: str
        when: str = Field(default="")
        post_build: bool = Field(default=False)

    class PatchBlocks(StrictModel):
        path: str
        block: str
        insertafter: str = Field(default="EOF")
        marker: str = Field(default="# {mark} ANSIBLE MANAGED BLOCK")
        when: str = Field(default="")
        post_build: bool = Field(default=False)

    class PatchFile(StrictModel):
        path: str
        commit: str = Field(default="HEAD")
        when: bool = Field(default=False)

    class Script(StrictModel):
        path: str
        post_build: bool = Field(default=False)

    class Task(StrictModel):
        path: str
        post_build: bool = Field(default=False)
        when: str = Field(default="")

    # mandatory fields ########################################################

    module: str = Field(description="Support module name, normally the repo name")
    version: str = Field(description="Version of the support module")

    # optional fields #########################################################

    dbds: Sequence[str] = Field(
        description="List of dbds the support module creates. "
        "Used to build a list for linking into the IOC",
        default=(),
    )
    libs: Sequence[str] = Field(
        description="List of libraries the support module creates. "
        "Used to build a list for linking into the IOC",
        default=(),
    )
    organization: str = Field(
        description="The git organization that owns the support module."
        "Used to generate the git remote from organization/module",
        default="https://github.com/epics-modules",
    )
    git_repo: str = Field(
        description="The git repository that contains the support module."
        "Use this to override the default organization/module",
        default=Field(
            default_factory=lambda data: f"{data['organization']}/{data['module']}"
        ),
    )
    protocol_files: Sequence[str] = Field(
        description="List of protocol files to copy into the runtime stage."
        "Path relative to support module root.",
        default=(),
    )
    recursive: bool = Field(
        description="Clone the support module with --recursive",
        default=False,
    )
    macro: str = Field(
        description="The macro used in configure/RELEASE for this module."
        "Defaults to the module name in uppercase",
        default=Field(default_factory=lambda data: data["module"].upper()),
    )
    remove_macros: Sequence[str] = Field(
        description="List of macros to remove from configure/RELEASE."
        "Sets MACRO_NAME= in the RELEASE.local file unless the macro already"
        "has a value (i.e. the module is aready built)",
        default=(),
    )
    make_options: str = Field(
        description="Options to pass to make. Used to build the support module",
        default="-j{{ ansible_processor_vcpus }}",
    )
    apt_developer: Sequence[str] = Field(
        description="List of apt packages to install in the developer target."
        "Uses the ubuntu package manager or deb files from download_extras",
        default=(),
    )
    apt_runtime: Sequence[str] = Field(
        description="List of apt packages to install in the runtime target."
        "Uses the ubuntu package manager or deb files from download_extras",
        default=(),
    )
    download_extras: Sequence[DownloadExtras] = Field(
        description="List of extra files to download (e.g. apt packages)",
        default=(),
    )
    runtime_files: Sequence[str] = Field(
        description="List of files to copy into the runtime stage"
        "Must be full path to the file.",
        default=(),
    )
    local_path: str = Field(
        description="Local path to the support module inside the conatiner. "
        "Full path required. Defaults to /epics/support/<module>",
        default=Field(default_factory=lambda data: f"/epics/support/{data['module']}"),
    )
    comment_out: Sequence[CommentOut] = Field(
        description="List of files to comment out lines in. "
        "Used unecessary lines from Makefiles to keep the build small"
        "Filepaths are relative to the root of the repository local path",
        default=(),
    )
    patch_blocks: Sequence[PatchBlocks] = Field(
        description="List of files to patch blocks of text into. "
        "Used to add extra flags to Makefiles, CONFIG_SITE etc.",
        default=(),
    )
    patch_lines: Sequence[PatchLines] = Field(
        description="List of files to patch lines in. "
        "Used to add extra flags to Makefiles, CONFIG_SITE etc.",
        default=(),
    )
    patch_file: PatchFile = Field(
        description="Apply a patch file to the repo. "
        "Optionally specify a commit to apply the patch to",
        default=(),
    )
    scripts: Sequence[Script] = Field(
        description="List of ad hoc bash scripts to execute. "
        "Paths are relative to the the ibek-support/module",
        default=(),
    )
    tasks: Sequence[Task] = Field(
        description="List of ad hoc ansible tasks to execute. "
        "Paths are relative to the the ibek-support/module",
        default=(),
    )
    remove_files_prebuild: Sequence[str] = Field(
        description="A list project relative files to remove pre build.",
        default=(),
    )


# dump the schema to a file
path = Path(__file__).parent / "support_install_variables.json"
with path.open(mode="w") as f:
    f.write(json.dumps(SupportVariables.model_json_schema()))
[]
