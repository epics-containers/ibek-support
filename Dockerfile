
ARG BASE=7.0.8ad3
ARG REGISTRY=ghcr.io/epics-containers
ARG DEVELOPER=${REGISTRY}/epics-base-developer:${BASE}

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# The devcontainer mounts the project root to /epics/generic-source
# Using the same location here makes devcontainer/runtime differences transparent.
ENV SOURCE_FOLDER=/epics/generic-source
# connect ioc source folder to its know location
COPY ioc /epics/ioc

# Get the current version of ibek
COPY requirements.txt requirements.txt
RUN pip install --upgrade -r requirements.txt

WORKDIR ${SOURCE_FOLDER}/ibek-support

# get all of ibek-support
COPY . .
RUN mkdir /epics/support/configure

# get ansible script into path
ENV PATH=$PATH:${SOURCE_FOLDER}/ibek-support/_ansible
# build all things that are dependencies in dependency order
RUN ansible.sh calc,sscan,asyn,busy,autosave,sequencer,std,StreamDevice -e skip_clean=true
RUN ansible.sh snmp,motor -e skip_clean=true
RUN ansible.sh pvxs -e skip_clean=true
RUN ansible.sh ADCore,ADGenICam -e skip_clean=true
# build everything else
RUN ansible.sh quadEM -e skip_clean=true
RUN ansible.sh all -e from_dockerfile=false -e skip_clean=true

# link everything including the kitchen sink into an IOC
RUN ansible.sh ioc
