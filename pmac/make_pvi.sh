# a record of how the pvi.device.yaml files were generated

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    --name pmacAxis \
    --template /epics/support/motor/db/basic_asyn_motor.db \
    --template /epics/support/pmac/db/dls_pmac_asyn_motor.template \
    --template /epics/support/pmac/db/eloss_kill_autohome_records.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    --name pmacController \
    --template /epics/support/pmac/db/pmacController.template \
    --template /epics/support/pmac/db/pmacStatus.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    --name ppmacController \
    --template /epics/support/pmac/db/pmacController.template \
    --template /epics/support/pmac/db/powerPmacStatus.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    --name pmacTrajectory \
    --template /epics/support/pmac/db/pmacControllerTrajectory.template

pvi convert device /workspaces/ioc-pmac/ibek-support/pmac  \
    --name pmacCSController \
    --template /epics/support/pmac/db/pmacCsController.template
