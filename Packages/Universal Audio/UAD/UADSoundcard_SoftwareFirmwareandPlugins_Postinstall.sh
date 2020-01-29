#!/bin/bash

########################################################################
#       UAD Soundcard Software, Firmware and Plugins Postinstall       #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

pkgReceipt=$(pkgutil --pkgs | grep "com.uaudio.installer.apollo")

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperFailed ()
{
#jamf Helper to advise that the install has failed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "UAD Soundcard Software, Firmware and Plugins" -description "Installation failed!

Please contact the IT Service Desk on 0345 058 4444 for assistance" -timeout 60 -button1 "Ok" -defaultButton "1"
}

function jamfHelperUpdateComplete ()
{
#Show a message via Jamf Helper that the install has completed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "UAD Soundcard Software, Firmware and Plugins" -description "Installation complete
Your Mac will now be rebooted" -alignDescription natural -timeout 15 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

#Kill the install in progess jamf Helper window
killall jamfHelper

if [[ "$pkgReceipt" != "" ]]; then
  jamfHelperUpdateComplete
else
  echo "UAD Soundcard Software, Firmware and Plugins package failed to install successfully"
  jamfHelperFailed
  exit 1
fi

exit 0
