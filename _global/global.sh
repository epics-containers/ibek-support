
#!/bin/bash

# For RTEMS builds, avoid also building for the host architecture

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo Setting RTEMS build to target the crosscompile only ...

    echo >> configure/CONFIG_SITE.Common.linux-x86_64
    echo "VALID_BUILDS=Host" >> configure/CONFIG_SITE.Common.linux-x86_64
fi