#!/usr/bin/env python
"""
A Pydantic model for the support install variables. Describes the variables
that can be supplied to the ansible role support described in

"""

import json
from pathlib import Path
from typing import Sequence

from pydantic import BaseModel, ConfigDict, Field


class SupportVariables(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        use_enum_values=True,
    )

    # nested classes ##########################################################

    class DownloadExtras(BaseModel):
        url: str
        dest: str

    class CommentOut(BaseModel):
        path: str
        regexp: str

    class PatchLines(BaseModel):
        path: str
        regexp: str
        line: str
        when: str = Field(default="")
        post_build: bool = Field(default=False)

    class PatchFile(BaseModel):
        path: str
        commit: str = Field(default="HEAD")
        when: bool = Field(default=False)

    class Scripts(BaseModel):
        path: str
        post_build: bool = Field(default=False)

    # mandatory fields ########################################################

    module: str = Field(description="Support module name, normally the repo name")
    version: str = Field(description="Version of the support module")
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

    # optional fields #########################################################

    organization: str = Field(
        description="The git organization that owns the support module."
        "Used to generate the git remote from organization/module",
        default="https://github.com/epics-modules",
    )
    git_repo: str = Field(
        description="The git repository that contains the support module."
        "Used to generate the git remote from organization/module",
        default=Field(
            default_factory=lambda data: f"{data['organization']}/{data['module']}"
        ),
    )
    macro: str = Field(
        description="The macro used in configure/RELEASE for this module."
        "Defaults to the module name in uppercase",
        default=Field(default_factory=lambda data: data["module"].upper()),
    )
    remove_macros: Sequence[str] = Field(
        description="List of macros to remove from configure/RELEASE."
        "Sets MACRO_NAME= in the RELEASE.local file",
        default=(),
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
    local_path: str = Field(
        description="Local path to the support module inside the conatiner."
        "Defaults to epics/support/<module>",
        default=Field(default_factory=lambda data: f"/epics/support/{data['module']}"),
    )
    comment_out: Sequence[CommentOut] = Field(
        description="List of files to comment out lines in."
        "Used unecessary lines from Makefiles to keep the build small",
        default=(),
    )
    patch_lines: Sequence[PatchLines] = Field(
        description="List of files to patch lines in."
        "Used to add extra flags to Makefiles, CONFIG_SITE etc.",
        default=(),
    )
    patch_file: PatchFile = Field(
        description="Apply a patch file to the repo."
        "Optionally specify a commit to apply the patch to",
        default=(),
    )
    scripts: Sequence[Scripts] = Field(
        description="List of scripts to execute",
        default=(),
    )


# dump the schema to a file
path = Path(__file__).parent / "support_install_variables.json"
with path.open(mode="w") as f:
    f.write(json.dumps(SupportVariables.model_json_schema()))
