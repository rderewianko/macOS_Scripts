#!/bin/bash

########################################################################
#           Redundant BitBar Scripts Extension Attribute               #
############### Written by Phil Walker Jan 2020 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$noLoADBundle" != "" ]]; then
  if [[ -e "$BitBarAD" ]] || [[ -e $LaunchSysPrefs ]]; then
    echo "<result>Found</result>"
  else
    echo "<result>Not Found</result>"
  fi
else
  echo "<result>N/A</result>"
fi

exit 0
