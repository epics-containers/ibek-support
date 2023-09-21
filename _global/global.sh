

#!/bin/bash

# this script is applied to patch all support modules and is always called
# by each support module's install.sh script

# TODO this needs updating with the new ibek support command set

# For RTEMS builds, avoid also building for the host architecture

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo Setting RTEMS build to target the crosscompile only ...

    echo >> configure/CONFIG_SITE.Common.linux-x86_64
    echo "VALID_BUILDS=Host" >> configure/CONFIG_SITE.Common.linux-x86_64
else
    echo No global changes needed for this build ...
fi
