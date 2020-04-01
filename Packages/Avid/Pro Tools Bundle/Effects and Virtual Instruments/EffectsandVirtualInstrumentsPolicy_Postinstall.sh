#!/bin/bash

########################################################################
#    Pro Tools Bundle - Effects and Virtual Instruments Postinstall    #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

pkgReceipt=$(pkgutil --pkgs | grep "ukptbundleeffectsandvirtualinstrumentsselfservice1.3")

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperFailed ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "The Effects and Virtual Instruments bundle failed to install successfully

No further software included in the Pro Tools bundle will be installed.

Please contact the IT Service Desk on 0345 058 4444 for assistance" -timeout 60 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$pkgReceipt" != "" ]]; then
  /usr/local/bin/jamf policy -event pt_bundle_WavesCentral
else
  echo "Effects and Virtual Instruments bundle package failed to install successfully"
  echo "Pro Tools bundle installation stopped!"
  jamfHelperFailed
  exit 1
fi

exit 0
