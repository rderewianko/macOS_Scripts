#!/bin/bash
#postinstall

########################################################################
#                            Functions                                 #
########################################################################

function launchDaemonStatus()
{
#Get the status of the launch daemon
checkLaunchD=$(launchctl list | grep "NoMADLoginAD.AuthCheck" | cut -f3)

if [[ "$checkLaunchD" == "com.bauer.NoMADLoginAD.AuthCheck" ]]; then
  echo "NoMAD Login AD auth check launch daemon loaded and started"
else
  echo "Something went wrong, NoMAD Login AD auth check launch daemon not currently loaded!"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Load and start the launch daemon
launchctl load /Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist
launchctl start /Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist

sleep 2
#Check the launch daemon has been loaded and started
launchDaemonStatus

exit 0
