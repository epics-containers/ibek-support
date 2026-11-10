# pvxs

pvxs is not built from ibek-support. epics-base builds it into the base image,
in [epics/scripts/make_pvxs.sh](https://github.com/epics-containers/epics-base/blob/main/epics/scripts/make_pvxs.sh),
and installs it at `/epics/support/pvxs`. `_ansible/RELEASE.global` points there.
