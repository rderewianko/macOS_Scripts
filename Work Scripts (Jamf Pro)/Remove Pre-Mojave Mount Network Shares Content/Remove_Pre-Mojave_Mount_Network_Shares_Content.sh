#!/bin/bash

########################################################################
#    Remove Pre-Mojave Mount Network Shares Script and Launch Agent    #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

launchAgent="/Library/LaunchAgents/com.bauer.networkshares.plist"
script="/Library/StartupItems/MountNetworkShares.sh"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -f "$launchAgent" ]] || [[ -f "$script" ]];then
  echo "Deleting Mount Network Shares LaunchAgent and script..."
  rm -f "$launchAgent"
  rm -f "$script"
else
  echo "Mount Network Shares LaunchAgent and script not found, nothing to do"
  exit 0
fi

if [[ ! -f "$launchAgent" ]] && [[ ! -f "$script" ]];then
  echo "Mount Network Shares LaunchAgent and script deleted successfully"
  exit 0
else
  echo "Deletion FAILED!"
  exit 1
fi
