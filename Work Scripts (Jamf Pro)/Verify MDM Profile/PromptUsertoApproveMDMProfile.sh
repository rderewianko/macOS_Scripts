#!/bin/zsh

########################################################################
#                  Prompt User to Approve MDM Profile                  #
################### Written by Phil Walker May 2021 ####################
########################################################################
# To be used post migration (On-Prem to Cloud)

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Seconds to wait before opening Self Service again
sleepTime="$4"
############ Variables for Jamf Pro Parameters - End ###################
# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Profiles installed
profileCheck=$(profiles list)
# User approval status
profileStatus=$(profiles status -type enrollment | grep "Approved" | awk '{print $3,$4,$5}')
# Jamf binary
jamfBinary="/usr/local/jamf/bin/jamf"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$profileStatus" != "" ]]; then
    echo "MDM profile already approved, nothing to do"
    echo "MDM Enrolment: ${profileStatus}"
else
    if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
        echo "No user logged in, will try again tomorrow"
    else
        if [[ "$profileCheck" =~ "There are no" ]]; then
            # Make sure the MDM profile is installed
            "$jamfBinary" mdm
            # Allow time for the majority of configuration profiles to install
            sleep "$sleepTime"
        fi
        # If Self Service is not already open, open it
        if [[ $(pgrep "Self Service") == "" ]]; then
            su -l "$loggedInUser" -c "open -F /Applications/Self\ Service.app"
            sleep 2
            if [[ $(pgrep "Self Service") != "" ]]; then
                echo "Self Service now open"
            else
                echo "Failed to open Self Service, exiting!"
                exit 1
            fi
        fi
        echo "Waiting for user approval..."
        sleep "$sleepTime"
        # Wait for the user to approve the MDM Profile
        profileStatus=$(profiles status -type enrollment | grep "Approved")
        if [[ "$profileStatus" == "" ]]; then
            while [[ "$profileStatus" == "" ]]; do
            	echo "Waiting for user approval..."
                # Kill Self Service so that the information on verifying the MDM profile is shown
                pkill "Self Service"
                # Open Self Service to make sure the user is shown the information
                su -l "$loggedInUser" -c "open -F /Applications/Self\ Service.app"
                # Wait for them to follow the instructions
                sleep "$sleepTime"
                # re-populate variable
	            profileStatus=$(profiles status -type enrollment | grep "Approved")
            done
                echo "MDM Profile approved by ${loggedInUser}"
                # Call the cancel all failed commands policy
                "$jamfBinary" policy -event cancel_failed_commands
                # Run recon
                "$jamfBinary" recon
        else
            echo "MDM Profile approved by ${loggedInUser}"
            # Call the cancel all failed commands policy
            "$jamfBinary" policy -event cancel_failed_commands
            # Run recon
            "$jamfBinary" recon
        fi
    fi
fi
exit 0