echo '
BUILD_IOCS=NO

CROSS_COMPILER_TARGET_ARCHS =

GLIBPREFIX=/usr

USR_INCLUDES += -I$(GLIBPREFIX)/include/glib-2.0
USR_INCLUDES += -I$(GLIBPREFIX)/lib/x86_64-linux-gnu/glib-2.0/include/

glib-2.0_DIR = $(GLIBPREFIX)/lib/x86_64-linux-gnu

ARAVIS_INCLUDE  = /usr/local/include/aravis-0.8/

' > configure/CONFIG_SITE.linux-x86_64.Common

echo '
# Generic RELEASE.local file for areadetector modules

SUPPORT=NotYetSet
AREA_DETECTOR=$(SUPPORT)
include $(SUPPORT)/configure/RELEASE
' > configure/RELEASE.local