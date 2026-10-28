pvi convert device /workspaces/ioc-tetramm/ibek-support/quadEM  \
    --header /epics/support/quadEM/quadEMApp/caenSrc/drvTetrAMM.h \
    --template /epics/support/quadEM/db/TetrAMM.template

pvi convert device /workspaces/ioc-tetramm/ibek-support/quadEM  \
    --header /epics/support/quadEM/quadEMApp/quadEMSrc/drvQuadEM.h \
    --template /epics/support/quadEM/db/quadEM.template

# 'pvi convert' generates an include of asynNDArrayDriver from the header file in quadEMSrc
# It should be replaced with the ADCore equivalent 'NDArrayBase' available in /epics/pvi-defs
sed -i 's/file_name: asynNDArrayDriver/file_name: NDArrayBase/' drvQuadEM.pvi.device.yaml