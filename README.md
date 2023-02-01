# ibek-defs
## ibek definition files

A central repository to hold the definition and patch files that enable ibek
to build EPICS support modules inside of a container.

## How to use

This repository should be included into every epics-containers generic IOC
as a folder called \<repo root\>/ibek-defs.

The best way to achieve this is demonstrated in
https://github.com/epics-containers/ioc-template.
This uses a git submodule to pull ibek-defs and lock in the version that
was last used. This is then copied into the container in a Dockerfile step.

## Purpose

TODO: this explanation could do with tidying up and I'm not sure it
belongs here anyway. perhaps move this to the epics-containers workflow
documentation and reference from here.

When A generic IOC is building it passes a ibek modules file
"\<generic ioc name\>.ibek.modules.yaml. This will contain references to
the support modules that the IOC depends upon and may also include
a patch script file for each of those support modules.

This repo supports generic IOCs as follows:-

- at IOC build time it provides a patch file script that makes any changes
  to the support source required to build it in the container. This is
  most likely involves creating a release/CONFIG_SITE.xxx file.

- at run time it provides a definition file per support module which
  allows the IOC to specify how it uses that support. This file will be name
  "\<support module name\>.ibek.def.yaml. The set of definition files are
  read by ibek in order to interpret the IOC instance yaml file and
  build an individual IOC's startup script.


