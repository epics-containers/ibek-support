# TODO: it would be better for us to have a way of updating the IOC
# CONFIG_SITE instead of moving the library
if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then
    # put pcre library in the library path for IOC linking
    cp /epics/support/PCRE/lib/libpcre.a /epics/support/StreamDevice/lib/RTEMS-beatnik
fi
