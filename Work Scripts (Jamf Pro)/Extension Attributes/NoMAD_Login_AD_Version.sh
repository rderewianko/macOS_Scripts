#!/bin/bash

########################################################################
#                        NoMAD Login AD Version                        #
################### written by Phil Walker May 2019 ####################
########################################################################

#Path to NoMAD Login AD bundle
NoLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

  if [[ -d "$NoLoADBundle" ]]; then
    NoLoADVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' ${NoLoADBundle}/Contents/Info.plist)
    echo "<result>$NoLoADVersion</result>"
  else
    echo "<result>Not Installed</result>"
  fi

exit 0
