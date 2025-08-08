#!/bin/bash

##
# (c) 2025 42Gears Mobility Systems Pvt Ltd. All Rights Reserved.
##

# Check if the version file exists and delete it
if [ -f "/usr/share/java/nix/version" ]; then
    rm "/usr/share/java/nix/version"
fi

# Check if the nix.properties file exists and delete it
if [ -f "/usr/share/java/nix/nix.properties" ]; then
    rm "/usr/share/java/nix/nix.properties"
fi

DQT='"'             # Single Quotes
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
PURPLE='\033[0;35m' # Purple
NC='\033[0m'        # No Color

CURLBIN="$(type -p curl)"
LSBLKBIN="$(type -p lsblk)"

installDPKGs () {

	# For updating the apt repositories to latest.
	sudo DEBIAN_FRONTEND=noninteractive dpkg --force-confdef --force-confold --configure -a
	apt update -y

  if [ -z "$CURLBIN" ]; then
    apt-get install curl -y > /dev/null;
  fi
  
 REQUIRED_PKG="debsums"
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG 2>/dev/null | grep "install ok installed")
 if [ "" = "$PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG
 fi
 output=$(sudo debsums debsums 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}debsums integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
  
 REQUIRED_PKG="libpam-pwquality"
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG 2>/dev/null | grep "install ok installed")
 if [ "" = "$PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG
 fi
 output=$(sudo debsums libpam-pwquality 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}libpam-pwquality integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi

 #For app analytics
 REQUIRED_PKG_WMCTRL="wmctrl"
 WMCTRL_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_WMCTRL 2>/dev/null | grep "install ok installed")
 if [ "" = "$WMCTRL_PKG_OK" ]; then
	apt-get --yes install $REQUIRED_PKG_WMCTRL
 fi
 output=$(sudo debsums wmctrl 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}wmctrl integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
 #For USB Enc
 REQUIRED_PKG_CRYPTSETUP="cryptsetup"
 CRYPTSETUP_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_CRYPTSETUP 2>/dev/null | grep "install ok installed")
 if [ "" = "$CRYPTSETUP_PKG_OK" ]; then
	apt-get --yes install $REQUIRED_PKG_CRYPTSETUP
 fi
 output=$(sudo debsums cryptsetup 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}cryptsetup integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
 #For user authentication
 REQUIRED_PKG_WMCTRL="perl"
 WMCTRL_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_WMCTRL 2>/dev/null | grep "install ok installed")
 if [ "" = "$WMCTRL_PKG_OK" ]; then
	apt-get --yes install $REQUIRED_PKG_WMCTRL
 fi
 output=$(sudo debsums perl 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}perl integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
#For Appstore
ubuntu_version=$(lsb_release -rs)
major_version=$(echo $ubuntu_version | cut -d. -f1)

ID_LINUX=$(grep -oP '^ID=\K.*' /etc/os-release)
VERSION_ID_LINUX=$(grep -oP '^VERSION_ID="?(\K[0-9]+)' /etc/os-release)

is_mint_version_22_or_higher=false
if [[ "$ID_LINUX" == *"mint"* ]] && (( VERSION_ID_LINUX >= 22 )); then
   is_mint_version_22_or_higher=true
fi

if $is_mint_version_22_or_higher || [ $major_version -ge 24 ]; then
        REQUIRED_PKG_libfuse2t64="libfuse2t64"
	libfuse2t64_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_libfuse2t64 2>/dev/null | grep "install ok installed")
 	if [ "" = "$libfuse2t64_PKG_OK" ]; then
  		apt-get --yes install $REQUIRED_PKG_libfuse2t64
 	fi
 	output=$(sudo debsums libfuse2t64 2>&1)
 	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     		echo -e "${RED}libfuse2t64 integrity failed, cannot proceed with installation${NC}"
    		exit 1
 	fi
else
        REQUIRED_PKG_libfuse2="libfuse2"
	libfuse2_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_libfuse2 2>/dev/null | grep "install ok installed")
 	if [ "" = "$libfuse2_PKG_OK" ]; then
  		apt-get --yes install $REQUIRED_PKG_libfuse2
 	fi
 	output=$(sudo debsums libfuse2 2>&1)
 	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     		echo -e "${RED}libfuse2 integrity failed, cannot proceed with installation${NC}"
    		exit 1
 	fi
fi
 
 #For json in shell 
 REQUIRED_PKG_JQ="jq"
 JQ_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_JQ 2>/dev/null | grep "install ok installed")
 if [ "" = "$JQ_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_JQ
 fi
 output=$(sudo debsums jq 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}jq integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi

 REQUIRED_PKG_HDPARM="hdparm"
 HDPARM_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_HDPARM 2>/dev/null | grep "install ok installed")
 if [ "" = "$HDPARM_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_HDPARM
 fi
 output=$(sudo debsums hdparm 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}hdparm integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi

   #remotesupport
 REQUIRED_PKG_APPINDICATOR="libayatana-appindicator3-dev"
 APPINDICATOR_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_APPINDICATOR 2>/dev/null | grep "install ok installed")
 if [ "" = "$APPINDICATOR_PKG_OK" ]; then
    apt-get --yes install $REQUIRED_PKG_APPINDICATOR
 fi
 
 #hardware
 REQUIRED_PKG_INXI="inxi"
 INXI_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_INXI 2>/dev/null | grep "install ok installed")
 if [ "" = "$INXI_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_INXI
 fi
 output=$(sudo debsums inxi 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}inxi integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
  #temperature
 REQUIRED_PKG_ACPI="acpi"
 ACPI_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_ACPI 2>/dev/null | grep "install ok installed")
 if [ "" = "$ACPI_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_ACPI
 fi
 output=$(sudo debsums acpi 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}acpi integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
  #alertmessage
 REQUIRED_PKG_LIBNOTIFY="libnotify-bin"
 LIBNOTIFY_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_LIBNOTIFY 2>/dev/null | grep "install ok installed")
 if [ "" = "$LIBNOTIFY_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_LIBNOTIFY
 fi
 output=$(sudo debsums libnotify-bin 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}libnotify-bin integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
 
 
 #locationtracking
 REQUIRED_PKG_GPSD="gpsd"
 GPSD_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_GPSD 2>/dev/null | grep "install ok installed")
 if [ "" = "$GPSD_PKG_OK" ]; then
  apt-get --yes install $REQUIRED_PKG_GPSD
 fi
 output=$(sudo debsums gpsd 2>&1)
 if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "FAILED" || echo "$output" | grep -q "No such file or directory" || echo "$output" | grep -q "not found"; then
     echo -e "${RED}gpsd integrity failed, cannot proceed with installation${NC}"
     exit 1
 fi
}

installRPMPKGs () {
    #For openSUSE package installation and integrity check
    if grep -qi "openSUSE" /etc/os-release; then
    	# For updating the zypper repositories to latest.
    	sudo zypper refresh
    	
	if [ -z "$CURLBIN" ]; then
		zypper install curl -y > /dev/null;
	fi
	
	zypper -q list installed libpwquality1 &>/dev/null && echo "" || zypper install -y libpwquality1
	output=$(rpm -V libpwquality1 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}libpwquality1 integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	zypper -q list installed libappindicator3-1 &>/dev/null && echo "" || zypper install -y libappindicator3-1

	zypper install -y ca-certificates
	output=$(rpm -V ca-certificates 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}ca-certificates integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	# for app analytics
	zypper install -y wmctrl
	output=$(rpm -V wmctrl 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}wmctrl integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	zypper install -y cryptsetup
	output=$(rpm -V cryptsetup 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}cryptsetup integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	zypper install -y perl 
	output=$(rpm -V perl 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}perl integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	# This is an alternative of libfuse2 in rpm
	zypper install -y fuse
	output=$(rpm -V fuse 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}fuse integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	zypper install -y jq
	output=$(rpm -V jq 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}jq integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi

	zypper install -y hdparm
	output=$(rpm -V hdparm 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}hdparm integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
	zypper install -y inxi
	output=$(rpm -V inxi 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}inxi integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
	zypper install -y acpi
	output=$(rpm -V acpi 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}acpi integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
	zypper install -y xdotool
	output=$(rpm -V xdotool 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}xdotool integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
	zypper install -y libnotify-tools
	output=$(rpm -V libnotify-tools 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}libnotify-tools integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
	
	#locationtracking
	zypper install -y gpsd
	output=$(rpm -V gpsd 2>&1)
	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		echo -e "${RED}gpsd integrity failed, cannot proceed with installation${NC}"
		exit 1
	fi
	
  else
  
  	# For updating the dnf repositories to latest.
  	sudo dnf makecache
  	
  	if [ -z "$CURLBIN" ]; then
    		yum install curl -y > /dev/null;
  	fi
  	
  	if grep -qi 'rocky' /etc/os-release; then
    	dnf --enablerepo=powertools install -y perl-JSON-XS
    	dnf config-manager --set-enabled crb
    	dnf install zenity -y
    	dnf config-manager --set-enabled devel
        dnf install -y xrandr
    fi
  
  	yum -q list installed libpwquality &>/dev/null && echo "" || yum install -y libpwquality
  	output=$(rpm -V libpwquality 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}libpwquality integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi

  	yum install -y ca-certificates
  	output=$(rpm -V ca-certificates 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}ca-certificates integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi

  	update-ca-trust force-enable
  	
  	centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/"//g')
  
  	# This pkg is required to install wmctrl only in CentOS
  	checkFedora=$(cat /etc/fedora-release 2>&1)
  	if echo "$checkFedora" | grep -q "No such file or directory"; then
  		yum install -y epel-release
  		output=$(rpm -V epel-release 2>&1)
  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       			echo -e "${RED}epel-release integrity failed, cannot proceed with installation${NC}"
       			exit 1
  		fi

        if [ "$centos_version" -ge 8 ]; then
            dnf install -y gnome-shell-extension-appindicator
        	dnf --enablerepo=powertools install perl-JSON-XS 	
        fi
  		

  		# This pkg is required for WebRTC in CentOS
  		yum install gtk3-devel
  		output=$(rpm -V gtk3-devel 2>&1)
  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       			echo -e "${RED}gtk3-devel integrity failed, cannot proceed with installation${NC}"
       			exit 1
  		fi
  	
  		# This pkg is required for WebRTC in CentOS
  		yum install libappindicator-gtk3
  		
  		# Required for patch management in less than or equal to CentOS 7
  		if [ "$centos_version" -le 7 ]; then
  			yum install -y dnf
  			output=$(rpm -V dnf 2>&1)
	  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
	       			echo -e "${RED}dnf integrity failed, cannot proceed with installation${NC}"
	       			exit 1
	  		fi
  		fi
  	fi

  	# for app analytics
  	yum install -y wmctrl
  	output=$(rpm -V wmctrl 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}wmctrl integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  
  	yum install -y cryptsetup
  	output=$(rpm -V cryptsetup 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}cryptsetup integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  
  	yum install -y perl 
  	output=$(rpm -V perl 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}perl integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  
  	# This is an alternative of libfuse2 in rpm
  	yum install -y fuse
  	output=$(rpm -V fuse 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}fuse integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  
  	yum install -y jq
  	output=$(rpm -V jq 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}jq integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  
  	yum install -y hdparm
  	output=$(rpm -V hdparm 2>&1)
  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       		echo -e "${RED}hdparm integrity failed, cannot proceed with installation${NC}"
       		exit 1
  	fi
  	
  	yum install -y inxi
  	
	if ! grep -qi 'rocky' /etc/os-release; then
		output=$(rpm -V inxi 2>&1)
	  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		   		echo -e "${RED}inxi integrity failed, cannot proceed with installation${NC}"
		   		exit 1
	  	fi
	fi  	


  	checkFedora=$(cat /etc/fedora-release 2>&1)
  	if ! echo "$checkFedora" | grep -q "No such file or directory"; then
  		dnf install -y libxcrypt-compat
  		output=$(rpm -V libxcrypt-compat 2>&1)
  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       			echo -e "${RED}libxcrypt-compat integrity failed, cannot proceed with installation${NC}"
       			exit 1
  		fi
      yum install -y xdotool
  		output=$(rpm -V xdotool 2>&1)
  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       			echo -e "${RED}xdotool integrity failed, cannot proceed with installation${NC}"
       			exit 1
  		fi
  	        dnf install -y gnome-shell-extension-appindicator
  	        		

    		# This pkg is required for WebRTC in Fedora
  		yum install -y libappindicator-gtk3-devel
  		
  		yum install -y acpi
  		output=$(rpm -V acpi 2>&1)
  		if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
       			echo -e "${RED}acpi integrity failed, cannot proceed with installation${NC}"
       			exit 1
  		fi
  	fi
  	
  	#locationtracking
  	if grep -qi "CentOS" /etc/os-release && [ "$centos_version" = "9" ]; then
		dnf install -y gpsd-minimal
		output=$(rpm -V gpsd-minimal 2>&1)
	  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
	   		echo -e "${RED}gpsd-minimal integrity failed, cannot proceed with installation${NC}"
	   		exit 1
	  	fi
	else
	  	yum install -y gpsd
	  	output=$(rpm -V gpsd 2>&1)
		if ! grep -qi 'rocky' /etc/os-release; then
		  	if echo "$output" | grep -q "not installed" || echo "$output" | grep -q "missing file" || echo "$output" | grep -q "SM5"; then
		   		echo -e "${RED}gpsd integrity failed, cannot proceed with installation${NC}"
		   		exit 1
		  	fi
		fi	  	

	fi
  fi
}

echo -e "${PURPLE}SureMDM Nix Installer version 7.13.7${NC}"
# Installer should run as root in order to successfully install Nix Service
if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Permission denied. Please run as root.${NC}"
  exit 126
fi

# ABSDIR is the absolute path where the installer is placed.
ABSDIR="$(dirname $(readlink -f $0))"

manageArchitectureDependentResources () {
  	# Get the system architecture
	ARCH=$(uname -m)
	case "$ARCH" in
	  aarch64)
		echo "Managing ARM/AARCH (aarch64) 64-bit Architecture resources"
		
		# For NextGen Remote-Support
      if [ -f "$ABSDIR/app/lib/libevent_32.so" ]; then
      	rm $ABSDIR/app/lib/libevent_32.so
      fi
		
		# For Nix Pam Module
		rm -rf $ABSDIR/app/lib/pam_sureidp.so $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp_arm_32.so
		mv $ABSDIR/app/lib/pam_sureidp_arm.so $ABSDIR/app/lib/pam_sureidp.so
		
		;;
	  armv7l|armhf)
		echo "Managing ARM/AARCH (armv7l|armhf) 32-bit Architecture resources"
		
		# For NextGen Remote-Support
       if [ -f "$ABSDIR/app/lib/libevent_32.so" ]; then
    	  rm $ABSDIR/app/lib/libevent.so
    	  mv $ABSDIR/app/lib/libevent_32.so $ABSDIR/app/lib/libevent.so
      fi
	  	
	  	# For Nix Pam Module
		rm -rf $ABSDIR/app/lib/pam_sureidp.so $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp_arm.so
		mv $ABSDIR/app/lib/pam_sureidp_arm_32.so $ABSDIR/app/lib/pam_sureidp.so
		
		;;
	  x86_64)
		echo "Managing Intel/AMD (x86_64) 64-bit Architecture resources"
		
		# For NextGen Remote-Support
		if [ -f "$ABSDIR/app/lib/libevent_32.so" ]; then
			rm $ABSDIR/app/lib/libevent_32.so
		fi
		
	  	# For Nix Pam Module
		rm -rf $ABSDIR/app/lib/pam_sureidp_arm_32.so $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp_arm.so
		
		;;
	  i686|i386)
		echo "Managing Intel/AMD (i686|i386) 32-bit Architecture resources"
		
		# For NextGen Remote-Support
	   	if [ -f "$ABSDIR/app/lib/libevent_32.so" ]; then
			rm $ABSDIR/app/lib/libevent.so
		  	mv $ABSDIR/app/lib/libevent_32.so $ABSDIR/app/lib/libevent.so
	  	fi
	  	
	  	# For Nix Pam Module
		rm -rf $ABSDIR/app/lib/pam_sureidp.so $ABSDIR/app/lib/pam_sureidp_arm_32.so $ABSDIR/app/lib/pam_sureidp_arm.so
		mv $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp.so
		
		;;
	  *)
		echo "Unknown architecture: $ARCH"
		;;
	esac
}

manageArchitectureDependentResources

# Check if Java is installed.
JAVABIN="$(type -p java)"
if [ -z "$JAVABIN" ]; then
    echo -e "${RED}Java Not Found. Installing Java for nix installation process.${NC}"
    # Install Java 8
    # Detect the Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        
        if [[ "$OS" == *"ubuntu"* || "$OS" == *"mint"* || "$OS" == *"raspbian"* || "$OS" == *"debian"* ]]; then
			# Installing for Debian-based distributions
			sudo apt update
			sudo apt install -y openjdk-8-jdk
			JAVABIN="$(type -p java)"
			if [ -z "$JAVABIN" ]; then
				sudo apt install -y openjdk-11-jdk
			fi
			JAVABIN="$(type -p java)"
			if [ -z "$JAVABIN" ]; then
				sudo apt install -y openjdk-17-jdk
			fi
		elif [[ "$OS" == *"fedora"* ]]; then
			# Installing for Fedora
			sudo dnf install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
		elif [[ "$OS" == *"centos"* ]]; then
			# Installing for CentOS/Rocky Linux
			sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
		elif [[ "$OS" == *"opensuse"* ]]; then
			# Installing for OpenSUSE
			sudo zypper install -y java-1_8_0-openjdk java-1_8_0-openjdk-devel
		elif [[ "$OS" == *"rocky"* ]]; then
			# Installing for rocky
			sudo dnf install -y java
		fi
    fi

    # Verify installation
    JAVABIN="$(type -p java)"
    if [ -n "$JAVABIN" ]; then
        echo -e "${PURPLE}Java installation successful, Proceeding with nix installation...${NC}"
    else
        echo -e "${RED}Failed to install Java/Javac, Terminating nix installation.${NC}"
        exit 127
    fi
fi

# Execute Java Test Jar to verify it cn run Java 7
"$JAVABIN" -jar "$ABSDIR/pilot/probe.jar" > /dev/null 2>&1
if [ $? != 0 ]; then
    echo -e "${RED}Either Java 7 (or higher version of JRE) is not installed or not set as default Java.${NC}"
    exit 127
fi

JAVADIR="/usr/share/java"
if [ ! -d "$JAVADIR" ]; then
	echo "Java directory does not exists, creating now.."
    mkdir -p "$JAVADIR"
    echo "Java Directory created: $JAVADIR"
fi

# Check if this platfrom is supported
#if [ ! -z "type -p systemctl" ] && [ ! -d "/lib/systemd/system" ]; then
if [ ! -z `type -p systemctl` ]; then
  echo -e "${GREEN}Found systemd init system.${NC}"
elif [[ `/sbin/init --version` =~ upstart ]]; then
  echo -e "${GREEN}Found upstart init system.${NC}"
elif [[ -f /etc/init.d/cron && ! -h /etc/init.d/cron ]]; then
  echo -e "${GREEN}Found sysv init system.${NC}"
else
  echo -e "${RED}SureMDM Nix installer is not supported on your platfrom${NC}"
  exit 1
fi

# Function to determine the package manager and install required packages
install_required_pkgs() {
    # Check if the system is Debian-based
    is_debian=false
    if [[ -f /etc/os-release ]] && grep -iq "debian" /etc/os-release; then
        is_debian=true
    fi

    # Check if dpkg command is available
    dpkg_path=$(command -v dpkg 2>/dev/null)

    # Check if rpm command is available
    rpm_path=$(command -v rpm 2>/dev/null)

    # Determine the package manager
    if [[ "$is_debian" == true && "$dpkg_path" == */dpkg ]]; then
        package_manager="DPKG"
        installDPKGs
    elif [[ "$rpm_path" == */rpm ]]; then
        package_manager="RPM"
        installRPMPKGs
    else
        package_manager="UNKNOWN"
    fi

    # Log the detected package manager
    echo -e "${GREEN}Package Manager set to $package_manager${NC}"
}

install_required_pkgs


IS_CLI_ENROLLMENT='false'

# Check for Arguments
if [ ! -z "$1" ]; then

  INPUT_PARAMETER=$(echo -n "$1" | tr -d '\n')
  
  # Check if the string is valid base64
  IS_BASE64=$(echo "$INPUT_PARAMETER" | base64 -d 2>/dev/null | base64 -w 0 2>/dev/null)

  if [[ "$IS_BASE64" == "$INPUT_PARAMETER" ]]; then
    IS_CLI_ENROLLMENT='true'

    INPUT_PARAMETER=$(echo "$INPUT_PARAMETER" | base64 -d)
    
    CUSTOMERID=$(echo "$INPUT_PARAMETER" | jq -r '.account_id') 
    SERVER=$(echo "$INPUT_PARAMETER" | jq -r '.server_url') 
    GROUP_PATH=$(echo "$INPUT_PARAMETER" | jq -r '.group_path')
    if [ -z "$GROUP_PATH" ]; then
      GROUP_PATH="Home"
    fi
    PASSWORD_HASH=$(echo "$INPUT_PARAMETER" | jq -r '.password') 
    Device_Name_Type=$(echo "$INPUT_PARAMETER" | jq -r '.device_name_type') 
    #Device_Name=$(echo "$INPUT_PARAMETER" | jq -r '.device_name') 
    USE_UUID=$(echo "$INPUT_PARAMETER" | jq -r '.is_uuid') 
    
    if [ -z "$USE_UUID" ] || [ "$USE_UUID" != "true" ]; then
      USE_UUID='n'
    else
      USE_UUID='y'
    fi

    RESTART_REQUIRED=$(echo "$INPUT_PARAMETER" | jq -r '.is_restart_required') 
    
    if [ -z "$RESTART_REQUIRED" ] || [ "$RESTART_REQUIRED" != "true" ]; then
      RESTART_REQUIRED='n'
    else
      RESTART_REQUIRED='y'
    fi

    IS_PROXY_REQUIRED=$(echo "$INPUT_PARAMETER" | jq -r '.is_proxy_required') 
    
    if [ -z "$IS_PROXY_REQUIRED" ] || [ "$IS_PROXY_REQUIRED" != "true" ]; then
      IS_PROXY_REQUIRED='n'
    else
      IS_PROXY_REQUIRED='y'
    fi

    if [[ "$IS_PROXY_REQUIRED" == "y" || "$IS_PROXY_REQUIRED" == "Y" ]]; then
      WEB_PROXY_URL=$(echo "$INPUT_PARAMETER" | jq -r '.proxy_url') 
      WEB_PROXY_PORT=$(echo "$INPUT_PARAMETER" | jq -r '.proxy_port') 
    fi

    IS_NEXTGEN_RS=$(echo "$INPUT_PARAMETER" | jq -r '.is_nextgen_rs') 

    if [[ "$IS_NEXTGEN_RS" == "f" || "$IS_NEXTGEN_RS" == "F" ]]; then
      IS_NEXTGEN_RS='n'
    else
      IS_NEXTGEN_RS='y'
    fi

    OVERWRITE="Yes"
  
  else
  # Arguments were passed. Parse each one.
  for ARGVAR in "$@"
  do
    case $ARGVAR in 
    -c*)
      CUSTOMERID=${ARGVAR#"-c"}
      echo -e "${GREEN}Account Id  = "$CUSTOMERID"${NC}"
      ;;
    -s* )
      SERVERURL=${ARGVAR#"-s"}
      echo -e "${GREEN}SureMDM Server = "$SERVERURL"${NC}"
      ;;
    -g*)
      GROUP_PATH=${ARGVAR#"-g"}
      echo -e "${GREEN}Enrollment Group Path  = "$GROUP_PATH"${NC}"
      ;;
    -p*)
      PASSWORD=${ARGVAR#"-p"}
      ;;
    -t*)
      Device_Name_Type=${ARGVAR#"-t"}
      if [ "$Device_Name_Type" == "1" ] || [ "$Device_Name_Type" == "2" ] || [ "$Device_Name_Type" == "3" ] || [ "$Device_Name_Type" == "4" ]; then
      	echo -e "${GREEN}Device Name Type  = "$Device_Name_Type"${NC}"
      fi
      ;;
    -d*)
      Device_Name=${ARGVAR#"-d"}
      if [ "$Device_Name_Type" == "3" ]; then
	      echo -e "${GREEN}Device Name = "$Device_Name"${NC}"
      fi
      ;;
    -e* )
      USEREMAIL=${ARGVAR#"-e"}
      echo -e "${GREEN}User Email = "$USEREMAIL"${NC}"
      ;;
    -np*)
      No_Proxy=${ARGVAR#"-np"}
      echo -e "${GREEN}No Proxy = "$No_Proxy"${NC}"
      ;;
    -nr* )
      IS_NEXTGEN_RS=${ARGVAR#"-nr"}
      echo -e "${GREEN}Use Next Gen RemoteSupport = "$IS_NEXTGEN_RS"${NC}"
      ;;
    -n* )
      MDM_USER_NAME=${ARGVAR#"-n"}
      echo -e "${GREEN}User Name = "$MDM_USER_NAME"${NC}"
      ;;
    -r* )
      RESTART_REQUIRED=${ARGVAR#"-r"}
      echo -e "${GREEN}Use RESTART REQUIRED = "$RESTART_REQUIRED"${NC}"
      ;;
    -u* )
      USE_UUID=${ARGVAR#"-u"}
      echo -e "${GREEN}Use UUID = "$USE_UUID"${NC}"
      ;;
    -wu* )
      WEB_PROXY_URL=${ARGVAR#"-wu"}
      echo -e "${GREEN}Use Web Proxy Address = "$WEB_PROXY_URL"${NC}"
      ;;
    -wp* )
      WEB_PROXY_PORT=${ARGVAR#"-wp"}
      echo -e "${GREEN}Use Web Proxy Port = "$WEB_PROXY_PORT"${NC}"
      ;;
    -w* )
      IS_PROXY_REQUIRED=${ARGVAR#"-w"}
      echo -e "${GREEN}Use Web Proxy = "$IS_PROXY_REQUIRED"${NC}"
      ;;
    -y* )
      OVERWRITE="Yes"
      echo -e "${GREEN}Assuming YES for all prompts${NC}"
      ;;
    *)
      echo -e "${RED}Invalid Argument "$ARGVAR"${NC}"
      echo -e "${PURPLE}Usage: sudo ./installnix.sh [-c<customerid>] [-s<serverpath>] [-g<group_path>] [-p<password>] [-t<device_name_type>] [-d<device_name>] [-r<is_restart_required>] [-u<use_uuid>] [-w<is_proxy_required>] [-wu<web_proxy_url>] [-wp<web_proxy_port] [-nr<next_gen_rs>] [-y]${NC}"
      exit 1
      ;;
    esac
  done
  fi
fi

# Automatically detect SAAS server path
if [ ! -z "$CUSTOMERID" ] && [ "$CUSTOMERID" != "1" ] && [ -z "$SERVERURL" ]; then
  SERVERURL="https://suremdm.42gears.com"
  echo -e "${GREEN}Assuming SureMDM Server = "$SERVERURL"${NC}"
fi

# Parse Server URL passed as parameters
if [ ! -z "$SERVERURL" ] && [ "$IS_CLI_ENROLLMENT" != 'true' ]; then
  case $SERVERURL in 
  http://*)
    SERVER=${SERVERURL#"http://"}
    SERVER=${SERVER%"/"}
    echo -e "${GREEN}Server = "$SERVER"${NC}"
    ;;
  https://* )
    SERVER=${SERVERURL#"https://"}
    SERVER=${SERVER%"/"}
    echo -e "${GREEN}Server = "$SERVER"${NC}"
    ;;
  *)
    echo -e "${RED}Invalid Server Path "$SERVERURL"${NC}"
    echo -e "${PURPLE}Server Path should start from http:// or https://${NC}"
    exit 1
    ;;
  esac
fi

# Put Nix related files in an appropriate directory
WORKDIR="/usr/share/java"
if [ -d "$WORKDIR" ]; then
  echo -e "${GREEN}Nix files will be installed to $WORKDIR/nix${NC}"
else
  # Almost all machines have /usr/share/java. In case if its no there, use /opt/nix
  WORKDIR="/opt/nix"
  if [ ! -d "/opt/nix" ]; then
    mkdir -p "/opt/nix";
  fi

  if [ ! -d "/opt/nix" ]; then
    echo -e "${RED}$WORKDIR does not exist.${NC}"
    exit 1
  else
    echo -e "${GREEN}Nix files will be installed to $WORKDIR/nix${NC}"
  fi
fi

# Check if destination directory already exists
WORKDIR="$WORKDIR/nix"
if [ -d "$WORKDIR" ]; then

  if [ "$OVERWRITE" = "Yes" ]; then
    echo -e "${GREEN}Overwriting existing Nix installation${NC}"
  else
    echo -e "${PURPLE}Destination directory already exists.${NC}"
    read -p "Do you wish to overwrite existing nix? (y/n) : " yn
    case $yn in
      [Yy]* ) echo -e "${GREEN}Overwriting existing Nix installation${NC}";;
      [Nn]* ) exit 2;;
      * )     exit 2;;
    esac
  fi

else
  mkdir $WORKDIR
fi

#Recreate nix/lib folder
rm -rf $WORKDIR/lib
mkdir $WORKDIR/lib

# Fix permissions and ownership of nix directory
if [ -d "$WORKDIR" ]; then
  chmod -R 0750 $WORKDIR
  chown root:root $WORKDIR
else
  echo -e "${RED}Cannot create directory $WORKDIR.${NC}"
  exit 1
fi

# Fix permissions and ownership of nix/Lib directory
if [ -d "$WORKDIR/lib" ]; then
  chmod -R 0750 $WORKDIR/lib
  chown root:root $WORKDIR/lib
else
  echo -e "${RED}Cannot create directory $WORKDIR/lib.${NC}"
  exit 1
fi

SURELOCKDIR="/usr/share/Surelock"

if [ -d "$SURELOCKDIR" ]; then
  rm -r $SURELOCKDIR
fi

mkdir $SURELOCKDIR

# Prepare the list of file to be copied
NIXJARFILE_S="$ABSDIR/app/nix.jar"
NIXROBOTJARFILE_S="$ABSDIR/app/nixr.jar"
NIXLIBFILE_S="$ABSDIR/app/lib/*.jar"
NIXCONFIGFILE_S="$ABSDIR/app/nix.conf"
NIXEVEFILE_S="$ABSDIR/bootstrap/nix.eve"
NIXAPPIMGFILE_S="$ABSDIR/Appstore.AppImage"
NIXKEYSTOREFILE_S="$ABSDIR/nix.keystore"
NIXAPPICONFILE_S="$ABSDIR/electron.png"
BUNDLEFILE="$ABSDIR/bundle"
NIXLIBFILE_SO="$ABSDIR/app/lib/*.so"
NIXLIBFILE_PP="$ABSDIR/app/lib/*.pp"
NIXSUREIDPLOGO="$ABSDIR/SureIDP.png"

NIXJARFILE_D="$WORKDIR/nix.jar"
NIXROBOTJARFILE_D="$WORKDIR/nixr.jar"
NIXLIBFILE_D="$WORKDIR/lib/"
NIXCONFIGFILE_D="$WORKDIR/nix.conf"
NIXDATAFILE_D="$WORKDIR/data"
NIXEVEFILE_D="$WORKDIR/nix.eve"
NIXAPPIMGFILE_D="$WORKDIR/Appstore.AppImage"
NIXKEYSTOREFILE_D="$WORKDIR/nix.keystore"
NIXAPPICONFILE_D="$WORKDIR/electron.png"

# Copy Files
cp $NIXJARFILE_S $NIXJARFILE_D
cp $NIXROBOTJARFILE_S $NIXROBOTJARFILE_D
cp $NIXLIBFILE_S $NIXLIBFILE_D
cp $NIXCONFIGFILE_S $NIXCONFIGFILE_D
cp $NIXAPPIMGFILE_S $NIXAPPIMGFILE_D
cp $NIXAPPICONFILE_S $NIXAPPICONFILE_D
cp $NIXKEYSTOREFILE_S $NIXKEYSTOREFILE_D
cp -r $BUNDLEFILE $SURELOCKDIR
cp $NIXLIBFILE_SO $NIXLIBFILE_D
cp $NIXLIBFILE_PP $NIXLIBFILE_D
cp $NIXSUREIDPLOGO $WORKDIR

# Get the system UUID using dmidecode and store it in the systemuuid variable
systemuuid=$(dmidecode -s system-uuid | tr -d '\n')

# Create the file and set the appropriate permissions
echo "$systemuuid" > "$SURELOCKDIR/systemuuid"
chmod 644 "$SURELOCKDIR/systemuuid"

if [ ! -f "$NIXEVEFILE_D" ]; then
  cp $NIXEVEFILE_S $NIXEVEFILE_D

  # Write ENV File
  UUID1=$(uuidgen)
  UUID2=$(uuidgen)

  VAL1=$(echo $UUID1 | base64)
  VAL2=$(echo $UUID2 | base64)

  sed -i "s/\("CYPHER_KEY_RUNTIME" * = *\).*\$/\1 $VAL1/" $NIXEVEFILE_D
  sed -i "s/\("CYPHER_VECTOR_RUNTIME" * = *\).*\$/\1 $VAL2/" $NIXEVEFILE_D
fi

chmod 0640 $NIXJARFILE_D
chown root:root $NIXJARFILE_D

chmod 0600 $NIXEVEFILE_D
chown root:root $NIXEVEFILE_D

chmod 0640 $NIXROBOTJARFILE_D
chown root:root $NIXROBOTJARFILE_D

chmod -R 0640 $NIXLIBFILE_D
chown -R root:root $NIXLIBFILE_D

chmod 0640 $NIXCONFIGFILE_D
chown root:root $NIXCONFIGFILE_D

chmod 0700 $NIXAPPIMGFILE_D
chmod 0700 $NIXAPPICONFILE_D
chmod 0600 $NIXKEYSTOREFILE_D

NIXSTOPFILE="$WORKDIR/NixStopped"
# delete nix stopFile

if [ -f "$NIXSTOPFILE" ]; then 
    echo "$NIXSTOPFILE exist"
	rm -f $NIXSTOPFILE
fi

NIXAPPIMAGEFILE="/opt/Appstore.AppImage"
if [ -f "$NIXAPPIMAGEFILE" ]; then
    echo "$NIXAPPIMAGEFILE exist"
	rm -f $NIXAPPIMAGEFILE
fi

# Configure things
while true; do

  # Ask For Customer ID if required
  if [ -z "$CUSTOMERID" ]; then
    while true; do
      read -p "Enter SureMDM Customer ID / Account ID: " CUSTOMERID
      if [ -z "$CUSTOMERID" ]; then
        echo -e "${RED}Customer ID / Account ID cannot be empty.${NC}"
      else
        break
      fi
    done
  fi

  # Ask for Server Path If required
  if [ "$CUSTOMERID" == "1" ]; then
    echo -e "${GREEN}You are running on-premise solution.${NC}"
    
    if [ -z "$SERVER" ]; then
      # Ask For Server Path
      while true; do
        read -p "Enter Server Path (Examples: 192.168.1.10, mymdm.exmaple.com/suremdm) " SERVER
        if [ -z "$SERVER" ]; then
          echo -e "${RED}Server Path cannot be empty.${NC}"
        else
          break
        fi
      done
    else
      echo -e "${RED}Server is $SERVER ${NC}"
    fi

  # Ask For Group Path if required
  if [ -z "$GROUP_PATH" ]; then
    while true; do
      read -p "Enter Enrollment Group Path: " GROUP_PATH
      if [ -z "$GROUP_PATH" ]; then
        echo -e "${RED}Enrollment Group Path cannot be empty.${NC}"
      else
        break
      fi
    done
  fi

  # Ask For Password if required
  if [ "$IS_CLI_ENROLLMENT" != 'true' ] && [ -z "$PASSWORD" ]; then
    read -s -p "Enter Enrollment Authentication Password: " PASSWORD
    echo " "
  fi
  
  # Ask For Web Proxy Requirement if required
  if [ -z "$IS_PROXY_REQUIRED" ] || [ "$IS_PROXY_REQUIRED" != "y" -a "$IS_PROXY_REQUIRED" != "Y" ]; then
    IS_PROXY_REQUIRED='n'
  fi

  # Ask For Web Proxy URL if required
  if [[ "$IS_PROXY_REQUIRED" == "y" || "$IS_PROXY_REQUIRED" == "Y" ]] && [ -z "$WEB_PROXY_URL" ]; then
    read -p "Enter Web Proxy Address: " WEB_PROXY_URL
  fi

  # Ask For Web Proxy Port if required
  if [[ "$IS_PROXY_REQUIRED" == "y" || "$IS_PROXY_REQUIRED" == "Y" ]] && [ -z "$WEB_PROXY_PORT" ]; then
    read -p "Enter Web Proxy Port(Default 3128): " WEB_PROXY_PORT
    if [ -z "$WEB_PROXY_PORT" ]; then
        WEB_PROXY_PORT=3128
    fi
  fi

  # Ask For Device Name Type if required
  if [ "$Device_Name_Type" != "1" ] && [ "$Device_Name_Type" != "2" ] && [ "$Device_Name_Type" != "3" ] && [ "$Device_Name_Type" != "4" ] || [ -z "$Device_Name_Type" ]; then
    while true; do
    echo -e "${PURPLE}Device Name Type:${NC}"
    echo -e "${PURPLE}1 = Serial Number${NC}"
    echo -e "${PURPLE}2 = Host Name${NC}"
    echo -e "${PURPLE}3 = Manual Name ${NC}"
    echo -e "${PURPLE}4 = System Generated Name${NC}"
      read -p "Enter Device Name Type: " Device_Name_Type
      if [ -z "$Device_Name_Type" ]; then
        echo -e "${RED}Device Name Type cannot be empty.${NC}"
      elif [ "$Device_Name_Type" != "1" ] && [ "$Device_Name_Type" != "2" ] && [ "$Device_Name_Type" != "3" ] && [ "$Device_Name_Type" != "4" ]; then
      	 echo -e "${RED}Enter Device Name Type Between 1 to 4.${NC}"
      else
        break
      fi
    done
  fi
  # Ask For Device Name if required
  if [ "$Device_Name_Type" == "3" ]; then
    if [ -z "$Device_Name" ]; then
      while true; do
        read -p "Enter Device Name: " Device_Name
        if [ -z "$Device_Name" ]; then
          echo -e "${RED}Device Name cannot be empty.${NC}"
        else
          break
        fi
      done
    fi
  fi

  else
    # SAAS Version
    if [ -z "$SERVER" ]; then
      SERVER="suremdm.42gears.com"
    fi
      
  fi

  # Ask For Group Path if required
  if [ -z "$GROUP_PATH" ]; then
    group_path=$(grep group_path $NIXCONFIGFILE_S | cut -d '=' -f2)
    while true; do
      if [ -z "$group_path" ]; then
        read -p "Enter Enrollment Group Path: " GROUP_PATH
      else
        read -p "Enter Enrollment Group Path (Default:-$group_path): " GROUP_PATH
      fi
      if [ -z "$GROUP_PATH" ]; then
        GROUP_PATH=$group_path
        if [ -z "$GROUP_PATH" ]; then
          echo -e "${RED}Enrollment Group Path cannot be empty.${NC}"
        else
          break
        fi
      else
        break
      fi
    done
  fi
  
  # Ask For Password if required
  if [ "$IS_CLI_ENROLLMENT" != 'true' ] && [ -z "$PASSWORD" ] && [ "$CUSTOMERID" != "1" ]; then
    read -s -p "Enter Enrollment Authentication Password: " PASSWORD
    echo " "
  fi

# Ask For Web Proxy Requirement if required
  if [ -z "$IS_PROXY_REQUIRED" ] || [ "$IS_PROXY_REQUIRED" != "y" -a "$IS_PROXY_REQUIRED" != "Y" ]; then
    IS_PROXY_REQUIRED='n'
  fi

  # Ask For Web Proxy URL if required
  if [[ "$IS_PROXY_REQUIRED" == "y" || "$IS_PROXY_REQUIRED" == "Y" ]] && [ -z "$WEB_PROXY_URL" ]; then
    read -p "Enter Web Proxy Address: " WEB_PROXY_URL
  fi

  # Ask For Web Proxy Port if required
  if [[ "$IS_PROXY_REQUIRED" == "y" || "$IS_PROXY_REQUIRED" == "Y" ]] && [ -z "$WEB_PROXY_PORT" ]; then
    read -p "Enter Web Proxy Port(Default 3128): " WEB_PROXY_PORT
    if [ -z "$WEB_PROXY_PORT" ]; then
        WEB_PROXY_PORT=3128
    fi
  fi

  # Ask For Device Name Type if required
  if [ "$Device_Name_Type" != "1" ] && [ "$Device_Name_Type" != "2" ] && [ "$Device_Name_Type" != "3" ] && [ "$Device_Name_Type" != "4" ] || [ -z "$Device_Name_Type" ]; then
    device_name_type=$(grep device_name_type $NIXCONFIGFILE_S | cut -d '=' -f2)
    while true; do
      echo -e "${PURPLE}Device Name Type:${NC}"
      echo -e "${PURPLE}1 = Serial Number${NC}"
      echo -e "${PURPLE}2 = Host Name${NC}"
      echo -e "${PURPLE}3 = Manual Name ${NC}"
      echo -e "${PURPLE}4 = System Generated Name${NC}"
      if [ -z "$device_name_type" ]; then
        read -p "Enter Device Name Type: " Device_Name_Type
      else
        read -p "Enter Device Name Type (Default:-$device_name_type): " Device_Name_Type
      fi
      if [ -z "$Device_Name_Type" ]; then
        Device_Name_Type=$device_name_type
        if [ -z "$Device_Name_Type" ]; then
          echo -e "${RED}Device Name Type cannot be empty.${NC}"
        else
          break
        fi
      elif [ "$Device_Name_Type" != "1" ] && [ "$Device_Name_Type" != "2" ] && [ "$Device_Name_Type" != "3" ] && [ "$Device_Name_Type" != "4" ]; then
        echo -e "${RED}Enter Device Name Type Between 1 to 4.${NC}"
      else
        break
      fi
    done
  fi

  # Ask For Device Name if required
  if [ "$Device_Name_Type" == "3" ]; then
    if [ -z "$Device_Name" ]; then
      device_name=$(grep device_name= $NIXCONFIGFILE_S | cut -d '=' -f2)
      while true; do
        if [ -z "$device_name" ]; then
          read -p "Enter Device Name: " Device_Name
        else
          read -p "Enter Device Name (Default:-$device_name):" Device_Name
        fi
        if [ -z "$Device_Name" ]; then
          Device_Name=$device_name
          if [ -z "$Device_Name" ]; then
            echo -e "${RED}Device Name cannot be empty.${NC}"
          else
            break
          fi
        else
          break
        fi
      done
    fi
  fi

  if [ "$(echo "$USE_UUID" | awk '{print tolower($0)}')" == "y" ] || [ "$(echo "$USE_UUID" | awk '{print tolower($0)}')" == "yes" ]; then
      USE_UUID="true"
      DEVICE_UUID=$(uuidgen)
  else
      USE_UUID="false"
  fi

  if [ "$(echo "$IS_NEXTGEN_RS" | awk '{print tolower($0)}')" == "n" ] || [ "$(echo "$IS_NEXTGEN_RS" | awk '{print tolower($0)}')" == "no" ]; then
      IS_NEXTGEN_RS="false"
  else
      IS_NEXTGEN_RS="true"
  fi
  
  if [ "$(echo "$RESTART_REQUIRED" | awk '{print tolower($0)}')" == "y" ] || [ "$(echo "$RESTART_REQUIRED" | awk '{print tolower($0)}')" == "yes" ]; then
      RESTART_REQUIRED="true"
  else
      RESTART_REQUIRED="false"
  fi
  
  # Print final values  
  echo -e "${GREEN}Account Id: $CUSTOMERID${NC}"
  NUMREGX='^[0-9]+$'
  if ! [[ $CUSTOMERID =~ $NUMREGX ]] ; then
    echo -e "${RED}Warning: $CUSTOMERID does not appear to be a valid Customer Id.${NC}"
  fi

  echo -e "${GREEN}Enrollment Group Path: "$GROUP_PATH"${NC}"

  echo -e "${GREEN}Device Name Type: "$Device_Name_Type"${NC}"
  if [ ! -z "$Device_Name" ]; then
    echo -e "${GREEN}Device Name: "$Device_Name"${NC}"
  fi

  # Check Server Status
  echo -e "${GREEN}SureMDM Server: https://$SERVER${NC}"
  CURLBIN="$(type -p curl)"
  if [ -z "$CURLBIN" ]; then
    echo -e "${RED}Curl command not found.${NC}"
  else
    if [ ! -z "$WEB_PROXY_URL" ]; then
      if curl -s --head  --request GET https://$SERVER/test.html -x "http://"$WEB_PROXY_URL":"$WEB_PROXY_PORT | grep "200" > /dev/null; then 
        echo -e "${GREEN}https://$SERVER is running${NC}"
      else
        echo -e "${RED}https://$SERVER is currently not reachable${NC}"
      fi
    else
      if curl -s --head  --request GET https://$SERVER/test.html | grep "200" > /dev/null; then 
        echo -e "${GREEN}https://$SERVER is running${NC}"
      else
        echo -e "${RED}https://$SERVER is currently not reachable${NC}"
      fi
    fi
  fi

  # Proceed if Ok
  if [ "$OVERWRITE" = "Yes" ]; then
    echo -e "${GREEN}Proceeding Nix installation${NC}"
    break
  else
    read -p "Is this information correct? Proceed? (y/N): " yn
    case $yn in
      [Yy]* ) break;;
      * ) echo -e "${PURPLE}Re-enter details${NC}"
        unset CUSTOMERID SERVER GROUP_PATH PASSWORD IS_PROXY_REQUIRED WEB_PROXY_URL WEB_PROXY_PORT Device_Name_Type Device_Name CURLBIN USE_UUID IS_NEXTGEN_RS RESTART_REQUIRED;;
    esac
  fi

done

if [[ -n $PASSWORD ]] && [ "$IS_CLI_ENROLLMENT" != 'true' ]; then
  PASSWORD_HASH=$(echo -n $PASSWORD | sha512sum  | awk '{print $1}')
fi

if [[ $WEB_PROXY_URL == https://* || $WEB_PROXY_URL == http://* ]]; then
    WEB_PROXY_URL=${WEB_PROXY_URL#https://}  # Remove "https://" if present
    WEB_PROXY_URL=${WEB_PROXY_URL#http://}   # Remove "http://" if present
fi

if [[ -n $PASSWORD_HASH ]];then
    sed -i "s/\("PASSWORD_HASH" * = *\).*\$/\1 $PASSWORD_HASH/" $NIXEVEFILE_D
fi

if [[ -n $DEVICE_UUID ]];then
    sed -i "s/\("DEVICE_UUID" * = *\).*\$/\1 $DEVICE_UUID/" $NIXEVEFILE_D
fi

# Write configuration
SERVER=$(echo "$SERVER" | sed 's/\//\\\//g')
sed -i "s/\("server" *= *\).*/\1$SERVER/" $NIXCONFIGFILE_D
sed -i "s/\("customer_id" *= *\).*/\1$CUSTOMERID/" $NIXCONFIGFILE_D
sed -i "/group_path/c\group_path=$GROUP_PATH" $NIXCONFIGFILE_D
sed -i "s/\("device_name_type" *= *\).*/\1$Device_Name_Type/" $NIXCONFIGFILE_D
sed -i "s/\("device_name" *= *\).*/\1$Device_Name/" $NIXCONFIGFILE_D
sed -i "s/\("use_uuid" *= *\).*/\1$USE_UUID/" $NIXCONFIGFILE_D
sed -i "s/\("next_gen_rs" *= *\).*/\1$IS_NEXTGEN_RS/" $NIXCONFIGFILE_D
sed -i "s/\("restart_required" *= *\).*/\1$RESTART_REQUIRED/" $NIXCONFIGFILE_D

if [ ! -z "$USEREMAIL" ]; then
  sed -i "s/\("email" *= *\).*/\1$USEREMAIL/" $NIXCONFIGFILE_D
fi

if [ ! -z "$MDM_USER_NAME" ]; then
  sed -i "s/\("name" *= *\).*/\1$MDM_USER_NAME/" $NIXCONFIGFILE_D
fi

if [ ! -z "$WEB_PROXY_URL" ] && [ "$IS_PROXY_REQUIRED" == "y" -o "$IS_PROXY_REQUIRED" == "Y" ]; then
  sed -i "s/\("proxyurl" *= *\).*/\1$WEB_PROXY_URL/" $NIXCONFIGFILE_D
fi

if [ ! -z "$WEB_PROXY_PORT" ] && [ "$IS_PROXY_REQUIRED" == "y" -o "$IS_PROXY_REQUIRED" == "Y" ]; then
  sed -i "s/\("proxyport" *= *\).*/\1$WEB_PROXY_PORT/" $NIXCONFIGFILE_D
fi

XDG_SESSION="$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}')"

if [ "${XDG_SESSION,,}" = "wayland" ]; then
  echo -e "Wayland detected${NC}"
else
  # Generate Remote Support Properties
  X11DISPLAYDIR="$XAUTHORITY"
  X11DISPLAYVAL="$DISPLAY"

  if [ -z "$X11DISPLAYVAL" ]; then
    X11DISPLAYVAL=':0'
  fi

  if [ -f "$X11DISPLAYDIR" ]; then
    echo "Environment Variables for Remote Support are: $X11DISPLAYDIR AND $X11DISPLAYVAL"
  else
    X11DISPLAY0=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
    X11USER=$(who | grep '('$X11DISPLAY0')' | awk '{print $1}')
    X11USERHOME=$(eval echo ~$X11USER)"/.Xauthority"
    if [ -f "$X11USERHOME" ]; then
      echo -e "${GREEN}$X11USERHOME will be used as default context for remote support.${NC}"
      X11DISPLAYDIR="$X11USERHOME"
    else
      echo -e "${RED}Remote support context not found.${NC}"
    fi
  fi

fi

removeremotesupportdesktopfile() {
	TARGET_DIR=".config/autostart"
	TARGET_FILE="remotesupport.desktop"
	for user_home in $(awk -F: '{ if ($6 ~ /^\/home\//) print $6 }' /etc/passwd); do
	    file_path="$user_home/$TARGET_DIR/$TARGET_FILE"
	    if [ -f "$file_path" ]; then
		rm "$file_path"
	    fi
	done
}
removeremotesupportdesktopfile

# Run corrosponding sh file for this platfrom #
if [ ! -z `type -p systemctl` ]; then
  # echo -e "${GREEN}Initiating installer for systemd platfrom.${NC}"
  source $ABSDIR/bootstrap/systemd.sh
elif [[ `/sbin/init --version` =~ upstart ]]; then
  # echo -e "${GREEN}Initiating installer for upstart platform.${NC}"
  source $ABSDIR/canonical/upstart.sh
elif [[ -f /etc/init.d/cron && ! -h /etc/init.d/cron ]]; then
  source $ABSDIR/legacy/sysvinit.sh  
else
  echo -e "${RED}SureMDM Nix installer is not supported on your platform${NC}"
  exit 1
fi
