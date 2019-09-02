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
#Check the logged in user is a local account
mobileAccount=$(dscl . read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)
#Mac model
macModel=$(sysctl -n hw.model)
#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
#Installer location
macOSInstaller="/Applications/Install macOS Mojave.app"
#Required disk space
requiredSpace="15"
##Check if free space > 15GB
osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$osMinor" -eq "12" ]]; then
	freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}' )
else
  freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}' )
fi

if [ -z ${freeSpace} ]; then
  freeSpace="5"
fi

if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
else
	spaceStatus="ERROR"
fi

if [[ -d "$macOSInstaller" ]]; then
  mojaveInstaller="FOUND"
else
  mojaveInstaller="NOT FOUND"
fi

#Upgrade Status
if [[ "$macModel" =~ "MacBook" ]] && [[ "$osShort" -eq "12" ]]; then
  if [[ -d "$noLoADBundle" ]]; then
    if [[ "$mobileAccount" == "" ]]; then
      echo "<result>Upgrade Ready</result>"
    else
      echo "<result>Disk space:${freeSpace}GB Installer:${mojaveInstaller} Mobile account:YES</result>"
    fi
  fi
else
  if [[ "$osMinor" -ge "14" ]]; then
    echo "<result>Not Required</result>"
  else
    if [[ "$spaceStatus" == "OK" ]] && [[ "$mojaveInstaller" == "FOUND" ]]; then
      echo "<result>Upgrade Ready</result>"
    else
      echo "<result>Disk space:${freeSpace}GB Installer:${mojaveInstaller}</result>"
    fi
  fi
fi

exit 0
