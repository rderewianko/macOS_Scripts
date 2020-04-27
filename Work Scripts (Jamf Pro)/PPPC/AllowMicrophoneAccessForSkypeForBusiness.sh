#!/bin/bash

########################################################################
#            Allow Skype for Business Access to the Microphone         #
#################### Written by Phil Walker Apr 2020 ###################
########################################################################

# Version 16.28.x currently doesn't prompt users for access to the Microphone
# This is a known issue that Microsoft have yet to fix

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Skype for Business App
skypeForBusiness="/Applications/Skype for Business.app"
# SfB Microphone access
micAccess=$(sqlite3 /Users/$loggedInUser/Library/Application\ Support/com.apple.TCC/TCC.db 'SELECT service, client, allowed FROM access' | grep "kTCCServiceMicrophone|com.microsoft.SkypeForBusiness|1")

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No user logged in, exiting..."
    exit 0
else
    if [[ -d "$skypeForBusiness" ]]; then
        echo "Skype for Business installed, continuing..."
        if [[ "$micAccess" != "" ]]; then
            echo "Skype for Business already has access to the Microphone for ${loggedInUser}"
            exit 0
        else
            # Close System Preferences
            killall "System Preferences" >/dev/null 2>&1
            # Allow SfB access to the Microphone
            sqlite3 /Users/$loggedInUser/Library/Application\ Support/com.apple.TCC/TCC.db "insert into access VALUES('kTCCServiceMicrophone','com.microsoft.SkypeForBusiness',0,1,1,NULL,NULL,NULL,'UNUSED',NULL,0,1541440109) ;" >/dev/null 2>&1
            # Re-populate the variable to check Mic access
            micAccess=$(sqlite3 /Users/$loggedInUser/Library/Application\ Support/com.apple.TCC/TCC.db 'SELECT service, client, allowed FROM access' | grep "kTCCServiceMicrophone|com.microsoft.SkypeForBusiness|1")
            if [[ "$micAccess" != "" ]]; then
                echo "Skype for Business granted access to the Microphone for ${loggedInUser}"
            else
                echo "Failed to grant Skype for Business access to the Microphone for ${loggedInUser}"
                exit 1
            fi
        fi
    else
        echo "Skype for Business not installed, no changes can be made"
    fi
fi

exit 0