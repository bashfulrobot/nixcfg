#!/bin/bash

##
# (c) 2018 42Gears Mobility Systems Pvt Ltd. All Rights Reserved.
##

BASHNAME=`basename "$0"`
if [ "$BASHNAME" == "systemd.sh" ]; then
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e "${RED}Invalid Usage of $BASHNAME. Please execute 'installnix.sh' instead.${NC}"
  exit 127
fi

# Check if systemd is installed.
SYSTEMDBIN="$(type -p systemctl)"
if [ -z "$SYSTEMDBIN" ]; then
  echo -e "${RED}This installer is not supported on this platform.${NC}"
  exit 127
fi

# Copy Upstart relatd files

NIXSERVICEFILE_S="$ABSDIR/bootstrap/nix.service"
NIXROBOTSERVICEFILE_S="$ABSDIR/bootstrap/nixr.service"

NIXSERVICEFILE_D="/lib/systemd/system/nix.service"
NIXROBOTSERVICEFILE_D="/lib/systemd/system/nixr.service"

# Check if systemd service is available
if [ ! -d "/lib/systemd/system" ]; then
  #suse has systemd in usr/lib/systemd/system
  if [ -d "/usr/lib/systemd/system" ];then
    NIXSERVICEFILE_D="/usr/lib/systemd/system/nix.service"
    NIXROBOTSERVICEFILE_D="/usr/lib/systemd/system/nixr.service"
  else
    echo -e "${RED}Cannot find /lib/systemd/system or usr/lib/systemd/system to install Service.${NC}"
    exit 1
  fi
fi

# Print service status and stop it

if systemctl list-units --type service | grep -q nix.service; then
    systemctl stop nix.service
fi
if systemctl list-units --type service | grep -q nixr.service; then
    systemctl stop nixr.service
fi

cp $NIXSERVICEFILE_S $NIXSERVICEFILE_D
cp $NIXROBOTSERVICEFILE_S $NIXROBOTSERVICEFILE_D

chmod 0640 $NIXSERVICEFILE_D
chown root:root $NIXSERVICEFILE_D

chmod 0640 $NIXROBOTSERVICEFILE_D
chown root:root $NIXROBOTSERVICEFILE_D

# Replace in config files
WORKDIRESC=$(echo "$WORKDIR" | sed 's/\//\\\//g')
if [[ $(grep -oP 'VERSION_ID="\K.(?=.)' /etc/os-release) == "1" && $(grep 'ID=ubuntu' /etc/os-release) ]]; then
  if [ -z "$No_Proxy" ]; then
        STARTCMD="/bin/bash -c 'systemd-notify --ready && $JAVABIN -Djava.library.path=$WORKDIR/lib -jar $NIXJARFILE_D'"
  else
        STARTCMD="'/bin/bash -c 'systemd-notify --ready && $JAVABIN -Djava.library.path=$WORKDIR/lib -Dhttp.nonProxyHosts=$No_Proxy -Dhttps.nonProxyHosts=$No_Proxy -jar $NIXJARFILE_D'"
  fi
else
  if [ -z "$No_Proxy" ]; then
        STARTCMD="$JAVABIN -Djava.library.path=$WORKDIR/lib -jar $NIXJARFILE_D"
  else
        STARTCMD="$JAVABIN -Djava.library.path=$WORKDIR/lib -Dhttp.nonProxyHosts=$No_Proxy -Dhttps.nonProxyHosts=$No_Proxy -jar $NIXJARFILE_D"
  fi
fi

STARTCMD=$(echo "$STARTCMD" | sed 's/\//\\\//g')

STARTROBOTCMD="$JAVABIN -Djava.library.path=$WORKDIR/lib -jar $NIXROBOTJARFILE_D"
STARTROBOTCMD=$(echo "$STARTROBOTCMD" | sed 's/\//\\\//g')
WORKDIRESCEVE="$WORKDIRESC\/nix.eve"

sed -i "s/\("WorkingDirectory" *= *\).*\$/\1$WORKDIRESC/" $NIXSERVICEFILE_D
sed -i "s/\("EnvironmentFile" *= *\).*\$/\1$WORKDIRESCEVE/" $NIXSERVICEFILE_D
sed -i "/^ExecStart=/c ExecStart=$STARTCMD" $NIXSERVICEFILE_D

sed -i "s/\("WorkingDirectory" *= *\).*\$/\1$WORKDIRESC/" $NIXROBOTSERVICEFILE_D
sed -i "s/\("EnvironmentFile" *= *\).*\$/\1$WORKDIRESCEVE/" $NIXROBOTSERVICEFILE_D
sed -i "s/\("ExecStart" *= *\).*\$/\1$STARTROBOTCMD/" $NIXROBOTSERVICEFILE_D

X11DISPLAYPROPERTY=${DQT}"XAUTHORITY=$X11DISPLAYDIR"${DQT}" "${DQT}"DISPLAY=$X11DISPLAYVAL"${DQT}
X11DISPLAYPROPERTY=$(echo "$X11DISPLAYPROPERTY" | sed 's/\//\\\//g')
sed -i "s/\("Environment" *= *\).*\$/\1$X11DISPLAYPROPERTY/" $NIXROBOTSERVICEFILE_D

# Reload and Start Service
systemctl daemon-reload

systemctl enable nix.service
systemctl enable nixr.service

systemctl start nix.service 
systemctl start nixr.service

sleep 10

for i in {1..2}; do
    if sudo service nix status | grep Status | grep -q "Started" || [ -z "$(sudo service nix status | grep Status)" ]; then
    	sleep 10      
    else
        systemctl status nix --lines=0 | sed '/Status: "Running"/ { s/Running/\x1b[32mSureMDM Enrollment completed successfully.\x1b[0m/; s/.*/\x1b[32m&\x1b[0m/; s/"//g; b }; /successfully/ s/.*/\x1b[32m&\x1b[0m/; s/"//g; /failed/ s/.*/\x1b[31m&\x1b[0m/; s/"//g' 
        break
    fi
done
if [ $i -eq 2 ]; then
    systemctl status nix --lines=0 | sed '/Status: "Started"/ { s/Started/Timeout occurred: Please wait a moment and then manually check SureMDM agent status./; s/.*/&/; s/"//g; b }; /successfully/ s/.*/&/; s/"//g; /failed/ s/.*/&/; s/"//g'
fi
