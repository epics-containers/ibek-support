
if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then
    # put pcre library in the library path for IOC linking
    cp /epics/support/PCRE/lib/libpcre.a /epics/support/StreamDevice/lib/RTEMS-beatnik
fi