#!/bin/bash
## preinstall

# NoMAD Login AD auth check launch daemon
launchDaemon="/Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist"
# NoMAD Login AD auth check script
noLoADScript="/Library/StartupItems/NoMADLoginAD_Auth_Check.sh"

# If the launch daemon already exists, stop, unload and delete it

if [[ -f "$launchDaemon" ]]; then

  launchctl stop "$launchDaemon"
  launchctl unload "$launchDaemon"
  rm -f "$launchDaemon"
  echo "NoMAD Login AD Auth Check launch daemon stopped, unloading and deleted"

fi

# If the script used by the launch daemon already exists, delete it

if [[ -f "$noLoADScript" ]]; then

  rm -f "$noLoADScript"
  echo "NoMAD Login AD auth check script deleted"

fi

exit 0
