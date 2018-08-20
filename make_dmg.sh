#!/bin/sh

# Builds a disk image containing installr and packages.

THISDIR=$(/usr/bin/dirname ${0})
DMGNAME="${THISDIR}/installr.dmg"
if [[ -e "${DMGNAME}" ]] ; then
    /bin/rm "${DMGNAME}"
fi
/usr/bin/hdiutil create -fs HFS+ -srcfolder "${THISDIR}/install" "${DMGNAME}"
