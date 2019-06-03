#!/bin/bash

########################################################################
#                        NoMAD Login AD Version                        #
################### written by Phil Walker May 2019 ####################
########################################################################

#Get the OS version
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ "$OSShort" -lt "14" ]]; then
  echo "<result></result>"
else
  #Path to NoMAD Login AD bundle
  NoLoADVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle/Contents/Info.plist)
  echo "<result>$NoLoADVersion</result>"
fi
