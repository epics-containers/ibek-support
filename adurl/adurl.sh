#!/bin/bash

echo '
CROSS_COMPILER_TARGET_ARCHS =

# Enable file plugins and source them all from ADSupport

WITH_GRAPHICSMAGICK = YES
GRAPHICSMAGICK_EXTERNAL = NO

WITH_JPEG     = YES
JPEG_EXTERNAL = NO

WITH_PVA      = YES
WITH_BOOST    = YES
' > configure/CONFIG_SITE.linux-x86_64.Common

echo '
# Generic RELEASE.local file that should work for all Support modules and IOCs

SUPPORT=NotYetSet
AREA_DETECTOR=$(SUPPORT)
include $(SUPPORT)/configure/RELEASE
' > configure/RELEASE.local
