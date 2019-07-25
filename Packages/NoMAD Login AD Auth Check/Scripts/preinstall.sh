#!/bin/bash
#preinstall

########################################################################
#                            Variables                                 #
########################################################################

#NoMAD Login AD auth check launch daemon
launchDaemon="/Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist"
#NoMAD Login AD auth check script
noLoADScript="/Library/StartupItems/NoMADLoginAD_Auth_Check.sh"

########################################################################
#                            Functions                                 #
########################################################################

function launchDaemonStatus()
{
#Get the status of the launch daemon
checkLaunchD=$(launchctl list | grep "NoMADLoginAD.AuthCheck" | cut -f3)

if [[ "$checkLaunchD" == "com.bauer.NoMADLoginAD.AuthCheck" ]]; then
  echo "NoMAD Login AD auth check launch daemon currently loaded"
  echo "Stopping and unloading the launch daemon..."
  launchctl stop "$launchDaemon"
  launchctl unload "$launchDaemon"
  sleep 2
else
  echo "NoMAD Login AD auth check launch daemon not loaded"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#If the launch daemon already exists, stop/unload and delete

if [[ -f "$launchDaemon" ]]; then

  launchDaemonStatus
  rm -f "$launchDaemon"

    #Re-populate variable for a post action check
    launchDaemon="/Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist"

    if [[ ! -f "$launchDaemon" ]]; then
      echo "Launch daemon deleted successfully"
    else
      echo "Launch daemon deletion FAILED!"
    fi

  launchDaemonStatus

fi

#If the script used by the launch daemon already exists, delete it

if [[ -f "$noLoADScript" ]]; then

  rm -f "$noLoADScript"

    #Re-populate variable for a post action check
    noLoADScript="/Library/StartupItems/NoMADLoginAD_Auth_Check.sh"

    if [[ ! -f "$noLoADScript" ]]; then
      echo "NoMAD Login AD auth check script deleted successfully"
    else
      echo "NoMAD Login AD auth check script deletion FAILED!"
    fi

fi

exit 0
