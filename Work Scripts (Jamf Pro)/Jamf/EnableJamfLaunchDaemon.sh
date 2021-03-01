#!/bin/zsh

########################################################################
#             Enable Jamf Recurring Check-In Launch Daemon             #
################## Written by Phil Walker Feb 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Check-in frequency
checkFreq="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Jamf Recurring Check-In Launch Daemon
launchDaemon="/Library/LaunchDaemons/com.jamfsoftware.task.1.plist"
# Launch Daemon status
launchDaemonStatus=$(launchctl list | grep "com.jamfsoftware.task.Every $checkFreq Minutes")

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -f "$launchDaemon" ]]; then
    echo "Jamf Pro Recurring Check-In Launch Daemon found"
    if [[ "$launchDaemonStatus" == "" ]]; then
        echo "Enabling the Jamf Pro Recurring Check-In Launch Daemon..."
        launchctl load -w "$launchDaemon"
        sleep 5
        # re-populate variable
        launchDaemonStatus=$(launchctl list | grep "com.jamfsoftware.task.Every $checkFreq Minutes")
        if [[ "$launchDaemonStatus" != "" ]]; then
            echo "Jamf Pro Recurring Check-In Launch Daemon enabled"
        else
            echo "Failed to enable the Jamf Pro Recurring Check-In Launch Daemon!"
            exit 1
        fi
    else
        echo "Jamf Pro Recurring Check-In Launch Daemon already enabled, nothing to do"
    fi
else
    echo "Jamf Pro Recurring Check-In Launch Daemon not found!"
    exit 1
fi
exit 0