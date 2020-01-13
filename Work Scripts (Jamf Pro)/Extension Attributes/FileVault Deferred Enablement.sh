#!/bin/bash

########################################################################
#                      FileVault Deferral Status                       #
################## written by Phil Walker July 2019 ####################
########################################################################

#Get OS version
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')
#FileVault deferral status
FV2Deferred=$(fdesetup status | sed -n 2p)

if [[ "$osShort" -ge "15" ]]; then
  echo "<result>N/A</result>"
else
  if [[ "$FV2Deferred" == "" ]] || [[ "$FV2Deferred" =~ "Encryption in progress" ]]; then
    echo "<result>Not deferred</result>"
  else
    FV2DeferralUser=$(fdesetup status | sed -n 2p | awk '{print $9}' | cut -d "'" -f2)
    if [[ "$FV2DeferralUser" == "" ]]; then
      echo "<result>FileVault deferred</result>"
    else
      echo "<result>FileVault deferred for: ${FV2DeferralUser}</result>"
    fi
  fi
fi

exit 0
