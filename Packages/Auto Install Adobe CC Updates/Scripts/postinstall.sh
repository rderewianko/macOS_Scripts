#!/bin/sh

########################################################################
#    Automatically Install All Adobe CC Application Updates Package    #
#                         postinstall script                           #    
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Launch Daemon
LaunchDaemon=/Library/LaunchDaemons/com.bauer.AdobeRUM.plist

########################################################################
#                            Functions                                 #
########################################################################

function launchDaemonStatus ()
{
#Get the status of the Launch Daemon
checkLaunchD=$(launchctl list | grep "com.bauer.AdobeRUM" | cut -f3)

if [[ "$checkLaunchD" == "com.bauer.AdobeRUM" ]]; then
  echo "Adobe RUM Launch Daemon loaded"
else
  echo "Something went wrong, Adobe RUM Launch Daemon not currently loaded!"
  echo "Reboot required"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#load the Launch Daemon
launchctl load "$LaunchDaemon"

sleep 2

#Check if the Launch Daemon was loaded successfully
launchDaemonStatus

exit 0