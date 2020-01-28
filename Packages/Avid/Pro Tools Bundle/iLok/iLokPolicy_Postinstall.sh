#!/bin/bash

########################################################################
#          Pro Tools Bundle - iLok License Manager postinstall         #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

pkgReceipt=$(pkgutil --pkgs | grep "com.paceap.pkg.eden.iLokLicenseManager")

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperFailed ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "iLok License Manager failed to install successfully

No further software included in the Pro Tools bundle will be installed.

Please contact the IT Service Desk on 0345 058 4444 for assistance." -timeout 60 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$pkgReceipt" != "" ]]; then
  /usr/local/bin/jamf policy -event pt_bundle_eLicenserManager
else
  echo "iLok License Manager package failed to install successfully"
  echo "Pro Tools bundle installation stopped!"
  jamfHelperFailed
  exit 1
fi

exit 0
