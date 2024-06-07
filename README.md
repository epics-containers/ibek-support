# ibek-support

This repo holds details of how to build EPICS support modules within
an epics-containers Generic IOC Dockerfile. For runtime, it also has details of
how to use features from each support module in an epics-container
IOC instance.

## Scope

This project targets
support modules that are available on github or other public
repositories. Facilities may choose to have an internal version of this
repo for support modules that are not public. Private Generic IOCs
would be free to mix support from both public and private ibek-support.

We expect that commonly used generic IOCs would be published to the
epics-containers github organisation or other public registry.
Such generic IOCs would be required to use public ibek-support only.


## Structure

Each EPICS support module has a folder in this repo. By convention,
the folder name is the same as the support module github repo name
(or other repo name).

Each support module folder contains:-

- install.sh:
  - a script that builds the support module inside of a container.
  This script is invoked by any Generic IOC build that requires the
  support module. The script can contain any bash  script commands that are
  required but would usually be a series of calls to `ibek support` functions.
  For an example see
  [install.sh](https://github.com/epics-containers/ibek-support/blob/main/ADSimDetector/install.sh)
  for the ADSimDetector support module.

- \<support module name\>.ibek.support.yaml:
  - a definition file that describes how the support module is used by
  an IOC instance. This file is read by ibek when building an IOC instance
  and is used to generate the startup script and database file. For an
  example see
  [ADSimDetector.ibek.support.yaml](https://github.com/epics-containers/ibek-support/blob/main/ADSimDetector/ADSimDetector.ibek.support.yaml)

- other:
  - any other files that are required to build the support module in the
  environment provided by the epics-base container image.
  The most straightforward support folders should only require the above two
  files. But perhaps a patch file might be required to make a support module
  build inside of a container for example.


## Versioning
An important aspect of ibek-support is that it will
retain backward compatibility with older versions of support modules going
forward from inception in October 2023. The install.sh script will be told
which version of the support moduel to build and will be able to detect which
OS and EPICS base version it is being built upon. The install.sh script will
be able to use this information to adjust any configuration that is required
by the environment.


## How to use

This repository should be included into every epics-containers generic IOC
as a submodule of the IOC's git repository. The generic IOC's Dockerfile
should then copy the ibek-support folder for each support module it
requires into the container and call its install.sh script.

For an example Dockerfile that demonstrates this see
[ioc-adsimdetector](https://github.com/epics-containers/ioc-adsimdetector/blob/main/Dockerfile)

For details of the ibek module support functions
[ibek's github page](https://github.com/epics-containers/ibek)

## An Example IOC

ibek-support and ibek enable us to build a generic IOC that uses support
for Aravis based cameras using this
[Dockerfile](https://github.com/epics-containers/ioc-adaravis/blob/main/Dockerfile).

We can then use the
[Aravis support module YAML](https://github.com/epics-containers/ibek-support/blob/main/ADAravis/ADAravis.ibek.support.yaml)
combined with an [IOC instance YAML file](https://github.com/epics-containers/ibek-support/blob/main/tests/ioc_instance/ioc.yaml)
to build an IOC instance.

The IOC instance will use ibek to generate this
[startup script](https://github.com/epics-containers/ibek-support/blob/main/tests/ioc_instance/st.cmd)
and this
[database subst file](https://github.com/epics-containers/ibek-support/blob/main/tests/ioc_instance/ioc.db)
when it launches. These two files are passed to the generic
IOC to make it into an IOC instance at container runtime.

## How to contribute

TODO: mention here how to use submodule in your ioc-xxx repo and how to
merge changes into ibek-support, also how to add to the CI to keep verifying
that the head of the repo is not broken for any support module.
ALSO: TODO point at the main epics-containers docs once updated to this latest
framework.




