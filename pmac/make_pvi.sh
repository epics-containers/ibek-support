# a record of how the pvi.device.yaml files were generated

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    /epics/support/pmac/pmacApp/src/pmacAxis.h \
    --template /epics/support/motor/db/basic_asyn_motor.db \
    --template /epics/support/pmac/db/dls_pmac_asyn_motor.template \
    --template /epics/support/pmac/db/eloss_kill_autohome_records.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    /epics/support/pmac/pmacApp/src/pmacController.h \
    --template /epics/support/pmac/db/pmacController.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    /epics/support/pmac/pmacApp/src/pmacTrajectory.h \
    --template /epics/support/pmac/db/pmacControllerTrajectory.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    /epics/support/pmac/pmacApp/src/pmacCSController.h \
    --template /epics/support/pmac/db/pmacCsController.template
