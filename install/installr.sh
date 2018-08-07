#!/bin/bash

# installr.sh
# A script to (optionally) erase a volume and install macos and
# additional packagesfound in a packages folder in the same directory
# as this script

if [[ $EUID != 0 ]] ; then
    echo "installr: Please run this as root, or via sudo."
    exit -1
fi

INDEX=0
OLDIFS=$IFS
IFS=$'\n'

# dirname and basename not available in Recovery boot
# so we get to use Bash pattern matching
BASENAME=${0##*/}
THISDIR=${0%$BASENAME}
PACKAGESDIR="${THISDIR}packages"
INSTALLMACOSAPP=$(echo "${THISDIR}Install macOS"*.app)
STARTOSINSTALL=$(echo "${THISDIR}Install macOS"*.app/Contents/Resources/startosinstall)

if [ ! -e "$STARTOSINSTALL" ]; then
    echo "Can't find an Install macOS app containing startosinstall in this script's directory!"
    exit -1
fi

echo "****** Welcome to installr! ******"
echo "macOS will be installed from:"
echo "    ${INSTALLMACOSAPP}"
echo "these additional packages will also be installed:"
for PKG in $(/bin/ls -1 "${PACKAGESDIR}"/*.pkg); do
    echo "    ${PKG}"
done
echo
echo "Available volumes:"
for VOL in $(/bin/ls -1 /Volumes) ; do
    if [[ "${VOL}" != "OS X Base System" ]] ; then
        let INDEX=${INDEX}+1
        VOLUMES[${INDEX}]=${VOL}
        echo "    ${INDEX}  ${VOL}"
    fi
done
read -p "Install to volume # (1-${INDEX}): " SELECTEDINDEX

SELECTEDVOLUME=${VOLUMES[${SELECTEDINDEX}]}

if [[ "${SELECTEDVOLUME}" == "" ]]; then
    exit 0
fi

read -p "Erase target volume before install (y/N)? " ERASETARGET

case ${ERASETARGET:0:1} in
    [yY] ) /usr/sbin/diskutil reformat "/Volumes/${SELECTEDVOLUME}" ;;
    * ) echo ;;
esac

echo
echo "Installing macOS to /Volumes/${SELECTEDVOLUME}..."

# build our startosinstall command
CMD="\"${STARTOSINSTALL}\" --agreetolicense --volume \"/Volumes/${SELECTEDVOLUME}\"" 

for ITEM in "${PACKAGESDIR}"/* ; do
    FILENAME="${ITEM##*/}"
    EXTENSION="${FILENAME##*.}"
    if [[ -e ${ITEM} ]]; then
        case ${EXTENSION} in
            pkg ) CMD="${CMD} --installpackage \"${ITEM}\"" ;;
            * ) echo "    ignoring non-package ${ITEM}..." ;;
        esac
    fi
done

# kick off the OS install
eval $CMD

