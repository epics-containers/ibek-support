
ARG BASE=7.0.8ad3
ARG REGISTRY=ghcr.io/epics-containers
ARG DEVELOPER=${REGISTRY}/epics-base-developer:${BASE}

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# The devcontainer mounts the project root to /epics/generic-source
# Using the same location here makes devcontainer/runtime differences transparent.
ENV SOURCE_FOLDER=/epics/generic-source
# connect ioc source folder to its know location
RUN ln -s ${SOURCE_FOLDER}/ioc ${IOC}

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
RUN ansible.sh calc,sscan,asyn,busy
RUN ansible.sh autosave
RUN ansible.sh sequencer,std,StreamDevice
RUN ansible.sh snmp
RUN ansible.sh motor
RUN ansible.sh pvxs
RUN ansible.sh ADCore
RUN ansible.sh ADGenICam
# build everything else
RUN ansible.sh all

# link everything including the kitchen sink into an IOC
COPY ioc ${SOURCE_FOLDER}/ioc
RUN ansible.sh ioc
