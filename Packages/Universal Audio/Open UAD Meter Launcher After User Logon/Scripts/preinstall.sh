#!/bin/bash

########################################################################
#        Open UAD Meter Launcher after user login - preinstall         #
################## Written by Phil Walker Jan 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

launchAgent="/Library/LaunchAgents/com.bauer.OpenUADMeterLauncherAfterUserLogin.plist"
startupItem="/Library/StartupItems/OpenUADMeterLauncherAfterUserLogin.sh"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -f "$launchAgent" ]]; then
  echo "Removing previous Launch Agent..."
  rm -f "$launchAgent"
  launchAgent="/Library/LaunchAgents/com.bauer.OpenUADMeterLauncherAfterUserLogin.plist"
    if [[ ! -f "$launchAgent" ]]; then
      echo "Previous Launch Agent removed successfully"
    else
      echo "Previous version removal failed"
    fi
fi

if [[ -f "$startupItem" ]]; then
  echo "Removing previous script..."
  rm -f "$startupItem"
  startupItem="/Library/StartupItems/OpenUADMeterLauncherAfterUserLogin.sh"
    if [[ ! -f "$startupItem" ]]; then
      echo "Previous script removed successfully"
    else
      echo "Previous version removal failed"
    fi
fi

exit 0
