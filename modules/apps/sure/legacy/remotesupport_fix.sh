#!/bin/bash

##
# (c) 2018 42Gears Mobility Systems Pvt Ltd. All Rights Reserved.
##

DQT='"'             # Single Quotes
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
PURPLE='\033[0;35m' # Purple
NC='\033[0m'        # No Color


# This should not be executed as root
if [ "$EUID" -eq 0 ]
  then echo -e "${RED}Please execute this from non-root user (without sudo or su) to view the help ${NC}"
  exit 126
fi

# Generate Remote Support Properties
NIXROBOTSERVICEFILE_D="/etc/init.d/nixr"
X11DISPLAYDIR="$XAUTHORITY"
X11DISPLAYVAL="$DISPLAY"

if [ -f "$X11DISPLAYDIR" ] && [ ! -z "$X11DISPLAYVAL" ]; then
  X11DISPLAYDIRESC=$(echo "$X11DISPLAYDIR" | sed 's/\//\\\//g')
  X11DISPLAYVALESC=$(echo "$X11DISPLAYVAL" | sed 's/\//\\\//g')

  echo -e "${PURPLE}Execute the following commands to configure Remote Support ${NC}"
  echo -e "${GREEN}sudo sed -i \"s/_XAUTHORITY_DIR_/$X11DISPLAYDIRESC/g\" $NIXROBOTSERVICEFILE_D${NC}"
  echo -e "${GREEN}sudo sed -i \"s/_DISPLAY_VAL_/$X11DISPLAYVALESC/g\" $NIXROBOTSERVICEFILE_D${NC}"
  echo -e "${GREEN}sudo $NIXROBOTSERVICEFILE_D restart${NC}"

else
  echo -e "${RED}No X11 or Xauth context found. Please make sure you have X-Window system installed.${NC}"
fi
