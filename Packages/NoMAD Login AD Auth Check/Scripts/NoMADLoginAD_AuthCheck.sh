#!/bin/bash

########################################################################
#     NoMAD Login AD login console authorisation mechanism check       #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
#Login console AD auth mechanism
systemLoginConsole=$(security authorizationdb read system.login.console | grep "CheckAD" | awk -F"[><]" '{print $3}')
#Log
logFile="/var/tmp/NoLoADAuth.log"
#Date and time
datetime=$(date +%d-%m-%Y\ %T)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$noLoADBundle" ]]; then
  echo "NoMAD Login AD installed"
    if [[ "$systemLoginConsole" =~ "NoMADLoginAD" ]]; then
      echo "NoMAD Login AD already set as the login window AD auth mechanism, nothing to do"
      exit 0
    else
      echo "$datetime :Resetting auth to use NoMAD Login AD as the login window AD auth mechanism" >> "$logFile"
      /usr/local/bin/authchanger -reset -AD
    fi
else
  echo "NoMAD Login AD not installed, nothing to do"
  exit 0
fi

#Re-populate system login console variable
systemLoginConsole=$(security authorizationdb read system.login.console | grep "CheckAD" | awk -F"[><]" '{print $3}')

if [[ "$systemLoginConsole" =~ "NoMADLoginAD" ]]; then
  echo "$datetime :NoMAD Login AD now set as the login window AD auth mechanism" >> "$logFile"
  exit 0
else
  echo "$datetime :Auth reset FAILED!" >> "$logFile"
  exit 1
fi

exit 0
