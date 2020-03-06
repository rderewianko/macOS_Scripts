#!/bin/bash

########################################################################
#               Pro Tools Bundle - Pro Tools Postinstall               #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')
#Mac model full name
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
#Package receipt
pkgReceipt=$(pkgutil --pkgs | grep "ukavidprotools2019.12")

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperFailed ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "Pro Tools failed to install successfully

No further software included in the Pro Tools bundle will be installed.

Please contact the IT Service Desk on 0345 058 4444 for assistance" -timeout 60 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

#Kill the install in progess jamf Helper window
killall jamfHelper

if [[ "$pkgReceipt" != "" ]]; then
  echo "Package receipt found"
  echo "Checking User Template package requirements..."
    if [[ "$osShort" -eq "14" ]]; then
      echo "${macModelFull} running macOS ${osFull}"
      /usr/local/jamf/bin/jamf policy -event pt2019_preferences_mojave
    elif [[ "$osShort" -ge "15" ]]; then
      echo "${macModelFull} running macOS ${osFull}"
      /usr/local/jamf/bin/jamf policy -event pt2019_preferences
    else
      echo "${macModelFull} running macOS ${osFull}, no User Template package requirement"
    fi
  /usr/local/bin/jamf policy -event pt_bundle_EffectsandVirtualInstruments
else
  echo "Pro Tools package failed to install successfully"
  echo "Pro Tools bundle installation stopped!"
  jamfHelperFailed
  exit 1
fi

exit 0
