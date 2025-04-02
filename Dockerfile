
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
RUN rm -rf .git # remove problematic git folder
RUN mkdir /epics/support/configure

# get ansible script into path
ENV PATH=$PATH:${SOURCE_FOLDER}/ibek-support/_ansible
# build all things that are dependencies in dependency order
RUN ansible.sh calc,sscan,asyn,busy
RUN ansible.sh autosave
RUN ansible.sh sequencer,std
RUN ansible.sh StreamDevice
RUN ansible.sh snmp,motor
RUN ansible.sh pvxs,ADCore,ADGenICAM
# build everything else
RUN ansible.sh all

# link everything including the kitchen sink into an IOC
COPY ioc ${SOURCE_FOLDER}/ioc
RUN ansible.sh ioc

##### runtime preparation stage ################################################
FROM developer AS runtime_prep

# get the products from the build stage and reduce to runtime assets only
RUN ibek ioc extract-runtime-assets /assets

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=runtime_prep /assets /

# install runtime system dependencies, collected from install.sh scripts
RUN ibek support apt-install-runtime-packages --skip-non-native

CMD ["bash", "-c", "${IOC}/start.sh"]
