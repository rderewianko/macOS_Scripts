#!/bin/bash

########################################################################
#                   macOS Upgrade Pre Check Status                     #
################## Written by Phil Walker Sept 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Check the logged in user has a local account (for 10.12 MacBooks only)
mobileAccount=$(dscl . read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)
#Mac model
macModel=$(sysctl -n hw.model)
#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
#Installer location
macOSInstaller="/Applications/Install macOS Mojave.app"
#Required disk space
requiredSpace="15"
#OS version
osMinor=$(/usr/bin/sw_vers -productVersion | awk -F. {'print $2'})

########################################################################
#                         Script starts here                           #
########################################################################

#Get available disk space
if [[ "$osMinor" -eq "12" ]]; then
	freeSpace=$(/usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}')
else
  freeSpace=$(/usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}')
fi

if [ -z ${freeSpace} ]; then
  freeSpace="5"
fi

#Confirm there is enough disk space for the upgrade
if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
fi

#Confirm the installer is available
if [[ -d "$macOSInstaller" ]]; then
  mojaveInstaller="Found"
else
	mojaveInstaller="Not Found"
fi

#Get account status of logged in user (Local or Mobile)
if [[ "$mobileAccount" == "" ]]; then
	accountStatus="Local"
else
	accountStatus="Mobile"
fi

#Upgrade Status
if [[ "$osMinor" -eq "12" ]] && [[ "$macModel" =~ "MacBook" ]]; then
	if [[ -d "$noLoADBundle" ]] && [[ "$accountStatus" == "Local" ]]; then
		if [[ "$spaceStatus" == "OK" ]] && [[ "$mojaveInstaller" == "Found" ]]; then
      echo "<result>Upgrade Ready</result>"
    else
      echo "<result>Disk space:${freeSpace}GB | Installer:${mojaveInstaller} | Account status:${accountStatus}</result>"
		fi
	else
  	echo "<result>Disk space:${freeSpace}GB | Installer:${mojaveInstaller} | Account status:${accountStatus}</result>"
	fi
elif [[ "$osMinor" -eq "12" ]] && [[ ! "$macModel" =~ "MacBook" ]]; then
	if [[ "$spaceStatus" == "OK" ]] && [[ "$mojaveInstaller" == "Found" ]]; then
		echo "<result>Upgrade Ready</result>"
	else
		echo "<result>Disk space:${freeSpace}GB | Installer:${mojaveInstaller}</result>"
	fi
fi

if [[ "$osMinor" -ge "14" ]]; then
  echo "<result>Not Required</result>"
elif [[ "$osMinor" -le "11" ]] || [[ "$osMinor" -eq "13" ]]; then
  if [[ "$spaceStatus" == "OK" ]] && [[ "$mojaveInstaller" == "Found" ]]; then
    echo "<result>Upgrade Ready</result>"
  else
    echo "<result>Disk space:${freeSpace}GB | Installer:${mojaveInstaller}</result>"
  fi
fi

exit 0
