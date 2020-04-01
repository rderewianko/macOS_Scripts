#!/bin/bash

########################################################################
#     Pro Tools Bundle - Effects and Virtual Instruments Preinstall    #
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

function jamfHelperDownloadInProgress ()
{
#Download in progress
su - $loggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -alignHeading natural -description "Downloading Effects and Virtual Instruments bundle..." -alignDescription natural &
jamfmsg1
}

########################################################################
#                         Script starts here                           #
########################################################################

#Show a message via Jamf Helper that the package is being downloaded
jamfHelperDownloadInProgress

exit 0
