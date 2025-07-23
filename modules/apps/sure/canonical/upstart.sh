#!/bin/bash

##
# (c) 2018 42Gears Mobility Systems Pvt Ltd. All Rights Reserved.
##

BASHNAME=`basename "$0"`
if [ "$BASHNAME" == "upstart.sh" ]; then
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e "${RED}Invalid Usage of $BASHNAME. Please execute 'installnix.sh' instead.${NC}"
  exit 127
fi

# Check if upstart is installed.
UPSTARTBIN="$(type -p initctl)"
if [ -z "$UPSTARTBIN" ]; then
  echo -e "${RED}Cannot find initctl. Exiting.${NC}"
  exit 127
fi

UPSTARTCHKCONF="$(type -p init-checkconf)"
if [ -z "$UPSTARTCHKCONF" ]; then
  echo -e "${RED}Warning: Cannot find init-checkconf. You may need to restart the system to complete Nix installation.${NC}"
fi

# Check if upstart is available
if [ ! -d "/etc/init" ]; then
  echo -e "${RED}Cannot find /etc/init to install service.${NC}"
  exit 1
fi
initctl status nix
initctl status nixr
initctl stop nix
initctl stop nixr

# Copy Upstart relatd files
NIXSERVICEFILE_S="$ABSDIR/canonical/nix.conf"
NIXROBOTSERVICEFILE_S="$ABSDIR/canonical/nixr.conf"

NIXSERVICEFILE_D="/etc/init/nix.conf"
NIXROBOTSERVICEFILE_D="/etc/init/nixr.conf"

cp $NIXSERVICEFILE_S $NIXSERVICEFILE_D
cp $NIXROBOTSERVICEFILE_S $NIXROBOTSERVICEFILE_D

chmod 0640 $NIXSERVICEFILE_D
chown root:root $NIXSERVICEFILE_D

chmod 0640 $NIXROBOTSERVICEFILE_D
chown root:root $NIXROBOTSERVICEFILE_D

#### Replace Texts ####

WORKDIRESC=$(echo "$WORKDIR" | sed 's/\//\\\//g')
JAVABINESC=$(echo "$JAVABIN" | sed 's/\//\\\//g')

X11DISPLAYDIRESC=$(echo "$X11DISPLAYDIR" | sed 's/\//\\\//g')
X11DISPLAYVALESC=$(echo "$X11DISPLAYVAL" | sed 's/\//\\\//g')

sed -i "s/_WORK_DIR_/$WORKDIRESC/g" $NIXSERVICEFILE_D
sed -i "s/_JAVA_BIN_/$JAVABINESC/g" $NIXSERVICEFILE_D
sed -i "s/_WORK_DIR_/$WORKDIRESC/g" $NIXROBOTSERVICEFILE_D
sed -i "s/_JAVA_BIN_/$JAVABINESC/g" $NIXROBOTSERVICEFILE_D
sed -i "s/_XAUTHORITY_DIR_/$X11DISPLAYDIRESC/g" $NIXROBOTSERVICEFILE_D
sed -i "s/_DISPLAY_VAL_/$X11DISPLAYVALESC/g" $NIXROBOTSERVICEFILE_D

#### Done ####

if [ ! -z "$UPSTARTCHKCONF" ]; then
  init-checkconf $NIXSERVICEFILE_D
  init-checkconf $NIXROBOTSERVICEFILE_D
fi

initctl reload-configuration

initctl start nix
initctl start nixr
initctl status nix
initctl status nixr

if [ -f "/var/log/upstart/nix.log" ]; then
  tail /var/log/upstart/nix.log
fi

if [ -f "/var/log/upstart/nix.log" ]; then
  tail /var/log/upstart/nixr.log
fi
