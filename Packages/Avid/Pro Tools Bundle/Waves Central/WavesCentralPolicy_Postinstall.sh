#!/bin/bash

########################################################################
#             Pro Tools Bundle - Waves Central Postinstall             #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

pkgReceipt=$(pkgutil --pkgs | grep "ukwavescentral11.0.58")

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperFailed ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "Waves Central failed to install successfully

No further software included in the Pro Tools bundle will be installed.

Please contact the IT Service Desk on 0345 058 4444 for assistance" -timeout 60 -button1 "Ok" -defaultButton "1"
}

function jamfHelperUpdateComplete ()
{
#Show a message via Jamf Helper that the install has completed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "Installation complete

Your Mac will now be rebooted" -alignDescription natural -timeout 15 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$pkgReceipt" != "" ]]; then
  jamfHelperUpdateComplete
else
  echo "Waves Central package failed to install successfully"
  echo "Pro Tools bundle installation did not complete successfully"
  echo "Waves Central can be deployed via Jamf Remote, if required"
  jamfHelperFailed
  exit 1
fi

exit 0
