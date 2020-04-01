#!/bin/bash

########################################################################
#                Pro Tools Bundle - Pro Tools Preinstall               #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user and store in variable
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperInstallInProgress ()
{
#Install is in progress
su - $loggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -windowPosition ur -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -alignHeading natural -description "Pro Tools installation in progress...

This may take up to 15 minutes to complete

When prompted to send anonymous usage data to Avid, please select either Yes or No to allow the installation to continue" -alignDescription natural &
jamfmsg1
}

########################################################################
#                         Script starts here                           #
########################################################################

#Show a message via Jamf Helper that the install is in progress
jamfHelperInstallInProgress

exit 0
