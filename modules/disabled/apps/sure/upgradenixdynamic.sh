#!/bin/bash

# Change version on every nix release carefully...
#V7.13.7
VERSION="7.13.7"
# Check which package is supported & install required packages
DPKG=$(type -p dpkg) 
RPM=$(type -p rpm)

# ABSDIR is the absolute path where the installer is placed.
ABSDIR="$(dirname $(readlink -f $0))"
ABSDIR=$ABSDIR/nix

JAVABIN="$(type -p java)"
WORKDIR="/usr/share/java/nix"
NIXSERVICEFILE_D="/lib/systemd/system/nix.service"
NIXROBOTSERVICEFILE_D="/lib/systemd/system/nixr.service"
NIXJARFILE_D="$WORKDIR/nix.jar"
NIXROBOTJARFILE_D="$WORKDIR/nixr.jar"
NIXEVEFILE=/usr/share/java/nix/nix.eve

#Creating Version File
echo -n "$VERSION" > "$WORKDIR/version"

# Add Keystore File
addOrUpdateNixKeystore() {
    if [ -e "$WORKDIR/nix.keystore" ]; then
        rm -r /usr/share/java/nix/nix.keystore
        cp -r $ABSDIR/nix.keystore $WORKDIR/
    else
        cp -r $ABSDIR/nix.keystore $WORKDIR/
    fi
}

addOrUpdateSureidpLogo() {
	if [ -e "$WORKDIR/SureIDP.png" ]; then
        rm -r /usr/share/java/nix/SureIDP.png
        cp -r $ABSDIR/SureIDP.png $WORKDIR/
    else
        cp -r $ABSDIR/SureIDP.png $WORKDIR/
    fi
}

addOrUpdateNixKeystore
addOrUpdateSureidpLogo

installDPKGs() {
	 # For package integrity check
	 REQUIRED_PKG="debsums"
	 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	 if [ "" = "$PKG_OK" ]; then
	  	apt-get --yes install $REQUIRED_PKG
	 fi
	 
	 REQUIRED_PKG="libpam-pwquality"
	 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	 if [ "" = "$PKG_OK" ]; then
	  	apt-get --yes install $REQUIRED_PKG
	 fi
	 
	 #For user authentication
	 REQUIRED_PKG_WMCTRL="perl"
	 WMCTRL_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_WMCTRL|grep "install ok installed")
	 if [ "" = "$WMCTRL_PKG_OK" ]; then
		apt-get --yes install $REQUIRED_PKG_WMCTRL
	 fi
	 
	 # Installing DEB Dependency Packages	
	 REQUIRED_PKG_WMCTRL="wmctrl"
	 WMCTRL_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_WMCTRL|grep "install ok installed")
	 if [ "" = "$WMCTRL_PKG_OK" ]; then
		apt-get --yes install $REQUIRED_PKG_WMCTRL
	 fi
	 
	 #For USB Enc
 	 REQUIRED_PKG_CRYPTSETUP="cryptsetup"
	 CRYPTSETUP_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_CRYPTSETUP|grep "install ok installed")
	 if [ "" = "$CRYPTSETUP_PKG_OK" ]; then
		apt-get --yes install $REQUIRED_PKG_CRYPTSETUP
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
	else
	        REQUIRED_PKG_libfuse2="libfuse2"
		libfuse2_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_libfuse2 2>/dev/null | grep "install ok installed")
	 	if [ "" = "$libfuse2_PKG_OK" ]; then
	  		apt-get --yes install $REQUIRED_PKG_libfuse2
	 	fi
	fi
	 
	 #For json in shell 
	 REQUIRED_PKG_JQ="jq"
	 JQ_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_JQ|grep "install ok installed")
	 if [ "" = "$JQ_PKG_OK" ]; then
	  apt-get --yes install $REQUIRED_PKG_JQ
	 fi

	 #USB Write Protection
	 REQUIRED_PKG_HDPARM="hdparm"
         HDPARM_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_HDPARM|grep "install ok installed")
    	 if [ "" = "$HDPARM_PKG_OK" ]; then
     		apt-get --yes install $REQUIRED_PKG_HDPARM
    	 fi
	 #For WebRTC
	 REQUIRED_PKG_APPINDICATOR="libayatana-appindicator3-dev"
     	 APPINDICATOR_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_APPINDICATOR|grep "install ok installed")
     	 if [ "" = "$APPINDICATOR_PKG_OK" ]; then
     	 	apt-get --yes install $REQUIRED_PKG_APPINDICATOR
      	 fi
      	 #hardware
	 REQUIRED_PKG_INXI="inxi"
	 INXI_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_INXI|grep "install ok installed")
	 if [ "" = "$INXI_PKG_OK" ]; then
	 	apt-get --yes install $REQUIRED_PKG_INXI
	 fi
	 
	 #temperature
	 REQUIRED_PKG_ACPI="acpi"
	 ACPI_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_ACPI|grep "install ok installed")
	 if [ "" = "$ACPI_PKG_OK" ]; then
	 	apt-get --yes install $REQUIRED_PKG_ACPI
	 fi
	 
	 #alertmessage
	 REQUIRED_PKG_LIBNOTIFY="libnotify-bin"
	 LIBNOTIFY_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_LIBNOTIFY|grep "install ok installed")
	 if [ "" = "$LIBNOTIFY_PKG_OK" ]; then
	 	apt-get --yes install $REQUIRED_PKG_LIBNOTIFY
	 fi
	 
	 
	 #locationtracking
	 REQUIRED_PKG_GPSD="gpsd"
	 GPSD_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG_GPSD|grep "install ok installed")
	 if [ "" = "$GPSD_PKG_OK" ]; then
	 	apt-get --yes install $REQUIRED_PKG_GPSD
	 fi
}

installRPMPKGs() {
	#For openSUSE package installation
  	if grep -qi "openSUSE" /etc/os-release; then
  		zypper -q list installed libpwquality1 &>/dev/null && echo "" || zypper install -y libpwquality1
  		zypper install -y ca-certificates
  		zypper install -y wmctrl
  		zypper install -y cryptsetup
  		zypper install -y fuse
  		zypper install -y hdparm
  		zypper -q list installed libappindicator3-1 &>/dev/null && echo "" || zypper install -y libappindicator3-1
  		zypper install -y inxi
  		zypper install -y acpi
		zypper install -y xdotool
		zypper install -y libnotify-tools
		zypper install -y gpsd
  	else
  		if grep -qi 'rocky' /etc/os-release; then
			dnf --enablerepo=powertools install -y perl-JSON-XS
		    	dnf config-manager --set-enabled crb
		    	dnf install zenity -y
		    	dnf config-manager --set-enabled devel
			dnf install -y xrandr
		fi
		yum -q list installed libpwquality &>/dev/null && echo "" || yum install -y libpwquality
		
		centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/"//g')
		# Installing RPM Dependency Packages
		checkFedora=$(cat /etc/fedora-release 2>&1)
	  	if echo "$checkFedora" | grep -q "No such file or directory"; then
	  	    	yum install -y epel-release
			yum install gtk3-devel
	  		yum install libappindicator-gtk3
	  		
		        if [ "$centos_version" -ge 8 ]; then
		            dnf install -y gnome-shell-extension-appindicator
		            dnf --enablerepo=powertools install perl-JSON-XS
		        fi
		        if [ "$centos_version" -le 7 ]; then
	  			yum install -y dnf
	  		fi  		
	  	fi
		yum install -y ca-certificates
		update-ca-trust force-enable
		yum install -y wmctrl
		yum install -y cryptsetup
		# This is an alternative of libfuse2 in rpm
	  	yum install -y fuse
	  	yum install -y jq
		yum install -y hdparm
		yum install -y inxi
		checkFedora=$(cat /etc/fedora-release 2>&1)
		if ! echo "$checkFedora" | grep -q "No such file or directory"; then
	  	     	dnf install -y libxcrypt-compat
	  	     	yum install -y xdotool
	  	     	dnf install -y gnome-shell-extension-appindicator
	  		yum install -y libappindicator-gtk3-devel
	  		yum install -y acpi
		fi
		
		#locationtracking
  		if grep -qi "CentOS" /etc/os-release && [ "$centos_version" = "9" ]; then
			yum install -y gpsd-minimal
		else
			yum install -y gpsd
		fi
	fi
}

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
    echo "${GREEN}Package Manager set to "$package_manager"${NC}"
}

install_required_pkgs


if [ ! -d "/usr/share/java/nix/lib" ]; then
    mkdir /usr/share/java/nix/lib
    chmod -R 0750 /usr/share/java/nix/lib
    chown root:root /usr/share/java/nix/lib
fi

manageArchitectureDependentResources () {
  	# Get the system architecture
	ARCH=$(uname -m)
	case "$ARCH" in
		aarch64)
			echo "Managing ARM/AARCH (aarch64) 64-bit Architecture resources"

			# For NextGen Remote-Support
			cp $ABSDIR/app/lib/libevent.so /usr/share/java/nix/lib/libeventnew.so
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
				cp $ABSDIR/app/lib/libevent_32.so /usr/share/java/nix/lib/libeventnew.so
				rm $ABSDIR/app/lib/libevent.so
			fi

			# For Nix Pam Module
			rm -rf $ABSDIR/app/lib/pam_sureidp.so $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp_arm.so
			mv $ABSDIR/app/lib/pam_sureidp_arm_32.so $ABSDIR/app/lib/pam_sureidp.so

		;;
		x86_64)
			echo "Managing Intel/AMD (x86_64) 64-bit Architecture resources"

			# For NextGen Remote-Support
			cp $ABSDIR/app/lib/libevent.so /usr/share/java/nix/lib/libeventnew.so
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
				cp $ABSDIR/app/lib/libevent_32.so /usr/share/java/nix/lib/libeventnew.so
				rm $ABSDIR/app/lib/libevent.so
			fi

			# For Nix Pam Module
			rm -rf $ABSDIR/app/lib/pam_sureidp.so $ABSDIR/app/lib/pam_sureidp_arm_32.so $ABSDIR/app/lib/pam_sureidp_arm.so
			mv $ABSDIR/app/lib/pam_sureidp_32.so $ABSDIR/app/lib/pam_sureidp.so

		;;
		*)
			echo "Unknown architecture: $ARCH"
		;;
	esac
	cp $ABSDIR/app/lib/pam_sureidp.so /usr/share/java/nix/lib/pam_sureidp.so
}

manageArchitectureDependentResources

updateServiceFileData() {

	STARTCMD="$JAVABIN -Djava.library.path=$WORKDIR/lib -jar $NIXJARFILE_D"
	STARTCMD=$(echo "$STARTCMD" | sed 's/\//\\\//g')
	NIX_SERVICESTATUS=$(cat "$NIXSERVICEFILE_D" | grep Djava.library.path)
	if [ -z "$NIX_SERVICESTATUS" ]; then
		sed -i "/ExecStart/c\ExecStart=$STARTCMD" $NIXSERVICEFILE_D
	fi

	STARTROBOTCMD="$JAVABIN -Djava.library.path=$WORKDIR/lib -jar $NIXROBOTJARFILE_D"
	STARTROBOTCMD=$(echo "$STARTROBOTCMD" | sed 's/\//\\\//g')
	NIXR_SERVICESTATUS=$(cat "$NIXROBOTSERVICEFILE_D" | grep Djava.library.path)
	if [ -z "$NIXR_SERVICESTATUS" ]; then
		sed -i "/ExecStart/c\ExecStart=$STARTROBOTCMD" $NIXROBOTSERVICEFILE_D
	fi
}

updateServiceFileData

cp $ABSDIR/app/*.jar /usr/share/java/nix/
rm -rf /usr/share/java/nix/lib/derby*
shopt -s extglob
cp $ABSDIR/app/lib/!(*.so) /usr/share/java/nix/lib/

updateLatestAppStore() {

	# Removing Older AppStore
	rm -f /usr/share/java/nix/electron.png
	rm -f /usr/share/java/nix/Appstore.AppImage
	rm -f /opt/Appstore.AppImage
	
	cp $ABSDIR/electron.png /usr/share/java/nix/
	cp $ABSDIR/Appstore.AppImage /usr/share/java/nix/
	cp $ABSDIR/Appstore.AppImage /opt/
	
	chmod 700 /usr/share/java/nix/electron.png
	chmod 700 /usr/share/java/nix/Appstore.AppImage
	chmod 555 /opt/Appstore.AppImage
}

updateConfFile() {
	USE_UUID_STATUS=$(cat "$WORKDIR/nix.conf" | grep use_uuid)
	if [ -z "$USE_UUID_STATUS" ]; then
		sed -i '/^device_name_type.*/a use_uuid=' $WORKDIR/nix.conf
	fi
}

addEnvironmentFile() {
	
	# Removing Surelock jar
	
	rm /usr/share/java/nix/surelock.jar

	#update nix.eve file

	cp $ABSDIR/bootstrap/nix.eve /usr/share/java/nix/

	# Write ENV File
	UUID1=$(uuidgen)
	UUID2=$(uuidgen)

	VAL1=$(echo $UUID1 | base64)
	VAL2=$(echo $UUID2 | base64)

	sed -i "s/\("CYPHER_KEY_RUNTIME" * = *\).*\$/\1 $VAL1/" $NIXEVEFILE
	sed -i "s/\("CYPHER_VECTOR_RUNTIME" * = *\).*\$/\1 $VAL2/" $NIXEVEFILE

	#make change in service file of newly added nix.ene file

	NIXSERVICEFILE_D=/usr/lib/systemd/system/nix.service

	NIXROBOTSERVICEFILE_D=/usr/lib/systemd/system/nixr.service

	NixServiceEnv=$(grep 'EnvironmentFile' NIXSERVICEFILE_D | grep cut -f1 -d: )

	NixRServiceEnv=$(grep 'EnvironmentFile' NIXROBOTSERVICEFILE_D | grep cut -f1 -d: )

	if [ -z "$NixServiceEnv" ]
	then
		echo "$NixServiceEnv not having envorinment file path"
		sed -i '/WorkingDirectory=/a EnvironmentFile='$NIXEVEFILE $NIXSERVICEFILE_D
	else
		echo "$NixServiceEnv having envorinment file path"
	fi

	if [ -z "$NixRServiceEnv" ]
	then
		echo "$NixRServiceEnv not having envorinment file path"
		sed -i '/WorkingDirectory=/a EnvironmentFile='$NIXEVEFILE $NIXROBOTSERVICEFILE_D
	else
		echo "$NixRServiceEnv having envorinment file path"
	fi
}

updateEnvironmentFile() {
	DEVICE_UUID_STATUS=$(cat "$WORKDIR/nix.eve" | grep DEVICE_UUID)
	if [ -z "$DEVICE_UUID_STATUS" ]; then
		sed -i -e '$aDEVICE_UUID =' $WORKDIR/nix.eve
	fi
}

addOrUpdateBundle() {
    if [ -d "/usr/share/Surelock/bundle" ]; then
        rm -r /usr/share/Surelock/bundle
        cp -r $ABSDIR/bundle /usr/share/Surelock
    else
        cp -r $ABSDIR/bundle /usr/share/Surelock
    fi
}
addOrUpdateBundle

reloadService() {
	systemctl daemon-reload
	systemctl enable nix.service
	systemctl enable nixr.service
}

updateLatestAppStore

if [ ! -f "$NIXEVEFILE" ]; then
    echo "Adding Environment Variable File Path to Services"
    addEnvironmentFile
    echo "Service File Updated"
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

systemuuid() {
	systemuuid=$(dmidecode -s system-uuid | tr -d '\n')
	SURELOCKDIR="/usr/share/Surelock"
	uuid_file="$SURELOCKDIR/systemuuid"
	if [ ! -f "$uuid_file" ]; then
	    echo "$systemuuid" > "$uuid_file"
	    chmod 644 "$uuid_file"
	fi
}

removeremotesupportdesktopfile
updateConfFile
updateEnvironmentFile
reloadService
systemuuid

conf_file_path="$WORKDIR/nix.conf"

if ! grep -q "^restart_required=" "$conf_file_path"; then
    sed -i '/device_name_type=/a restart_required=' "$conf_file_path"
fi

if ! grep -q "^next_gen_rs=" "$conf_file_path"; then
    sed -i '/use_uuid=/a next_gen_rs=true' "$conf_file_path"
fi

if [[ $(grep -oP 'VERSION_ID="\K.(?=.)' /etc/os-release) == "1" && $(grep 'ID=ubuntu' /etc/os-release) ]]; then
    sed -i '/^ExecStart=/c ExecStart=/bin/bash -c '\''systemd-notify --ready && /usr/bin/java -Djava.library.path=/usr/share/java/nix/lib -jar /usr/share/java/nix/nix.jar'\''' /lib/systemd/system/nix.service && sleep 5 && systemctl daemon-reload && service nixr restart && service nix restart &
else
    sleep 5 && service nixr restart && service nix restart &
fi

echo "Internal Upgrade Complete"
