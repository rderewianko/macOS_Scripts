#!/bin/bash

########################################################################
#     Force Self Service to prompt for MDM profile user approval       #
################### Written by Phil Walker Apr 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Jamf binary
jamfBinary="/usr/local/jamf/bin/jamf"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, will try again tomorrow"
else
    # Download required CA certificate(s) from the JSS
    "$jamfBinary" trustJSS
    # Enforce management framework from the JSS
    "$jamfBinary" manage
    # Allow the MDM profile to be installed at the user level
    "$jamfBinary" mdm -userLevelMdm
    # Make sure Self Service is not already open
    if [[ $(pgrep "Self Service") != "" ]]; then
        pkill "Self Service"
    fi
    # Open Self Service
    su -l "$loggedInUser" -c "open -F /Applications/Self\ Service.app"
    # Wait for the user to approve the MDM Profile
    profileStatus=$(profiles status -type enrollment | grep "Approved")
    while [[ "$profileStatus" == "" ]]; do
	    echo "Waiting for user approval..."
	    sleep 300
        # Kill Self Service so that the information on verifying the MDM profile is shown
        pkill "Self Service"
        # Open Self Service to make sure the user is shown the information
        su -l "$loggedInUser" -c "open -F /Applications/Self\ Service.app"
        # re-populate variable
	    profileStatus=$(profiles status -type enrollment | grep "Approved")
    done
    echo "MDM Profile approved by ${loggedInUser}"
    # Call the cancel all failed commands policy
    "$jamfBinary" policy -event cancel_failed_commands
fi
exit 0