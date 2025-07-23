#!/bin/bash

##
# (c) 2018 42Gears Mobility Systems Pvt Ltd. All Rights Reserved.
##

BASHNAME=`basename "$0"`
if [ "$BASHNAME" == "sysvinit.sh" ]; then
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e "${RED}Invalid Usage of $BASHNAME. Please execute 'installnix.sh' instead.${NC}"
  exit 127
fi

# Check if sysv-init is available
if [[ ! -f /etc/init.d/cron &&  -h /etc/init.d/cron ]]; then
  echo -e "${RED}Cannot find sysv-init. Exiting.${NC}"
fi

/etc/init.d/nix stop
/etc/init.d/nixr stop

# Copy sysv-init related files
NIXSERVICEFILE_S="$ABSDIR/legacy/nix"
NIXROBOTSERVICEFILE_S="$ABSDIR/legacy/nixr"


NIXSERVICEFILE_D="/etc/init.d/nix"
NIXROBOTSERVICEFILE_D="/etc/init.d/nixr"


cp $NIXSERVICEFILE_S $NIXSERVICEFILE_D
cp $NIXROBOTSERVICEFILE_S $NIXROBOTSERVICEFILE_D



chmod 0555 $NIXSERVICEFILE_D
chown root:root $NIXSERVICEFILE_D

chmod 0555 $NIXROBOTSERVICEFILE_D
chown root:root $NIXROBOTSERVICEFILE_D

#### Replace Texts ####

WORKDIRESC=$(echo "$WORKDIR" | sed 's/\//\\\//g')
JAVABINESC=$(echo "$JAVABIN" | sed 's/\//\\\//g')

sed -i "s/_WORK_DIR_/$WORKDIRESC/g" $NIXSERVICEFILE_D
sed -i "s/_JAVA_BIN_/$JAVABINESC/g" $NIXSERVICEFILE_D
sed -i "s/_WORK_DIR_/$WORKDIRESC/g" $NIXROBOTSERVICEFILE_D
sed -i "s/_JAVA_BIN_/$JAVABINESC/g" $NIXROBOTSERVICEFILE_D

if [ -f "$X11DISPLAYDIR" ] && [ ! -z "$X11DISPLAYVAL" ]; then
  X11DISPLAYDIRESC=$(echo "$X11DISPLAYDIR" | sed 's/\//\\\//g')
  X11DISPLAYVALESC=$(echo "$X11DISPLAYVAL" | sed 's/\//\\\//g')

  sed -i "s/_XAUTHORITY_DIR_/$X11DISPLAYDIRESC/g" $NIXROBOTSERVICEFILE_D
  sed -i "s/_DISPLAY_VAL_/$X11DISPLAYVALESC/g" $NIXROBOTSERVICEFILE_D
fi


# Reload and Start Service
/etc/init.d/nix restart
/etc/init.d/nixr restart

chkconfig nix on
chkconfig nixr on

/etc/init.d/nix status
/etc/init.d/nixr status

chkconfig nix
chkconfig nixr

if [ ! -f "$X11DISPLAYDIR" ] || [  -z "$X11DISPLAYVAL" ]; then
# Remote Support was not configured
echo -e "${PURPLE}*****************************************************${NC}"
echo -e    "${RED}* Unable to configure Remote Support${NC}"
echo -e  "${GREEN}* If X11 is available for this system, execute${NC}"
echo -e  "${GREEN}* $. $ABSDIR/legacy/remotesupport_fix.sh${NC}"
echo -e  "${GREEN}* (without sudo or su)to view help for Remote Support${NC}"
echo -e "${PURPLE}*****************************************************${NC}"

fi
