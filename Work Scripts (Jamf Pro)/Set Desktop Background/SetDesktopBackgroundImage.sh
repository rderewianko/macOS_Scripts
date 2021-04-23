#!/bin/zsh

########################################################################
#           Set Bauer Media Group Desktop Background Image             #
################## Written by Phil Walker Mar 2020 #####################
########################################################################
# Edit Mar 2021

# Pre-Reqs: 
# 1. desktoppr (https://github.com/scriptingosx/desktoppr)
# 2. Desktop Background image of your choice
# Command to set Desktop Background must be run as the user

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# desktoppr binary
desktopprBinary="/usr/local/bin/desktoppr"
# Desktop Background Image path
imagePath="/usr/local/BauerMediaGroup/Desktop/BauerMediaGroupDesktop.heic"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    exit 1
else
    # Confirm the image exists
    if [[ ! -f "$imagePath" ]]; then
        echo "Bauer Media Group Desktop Background image not found, exiting"
        exit 1
    fi
    # Confirm that desktoppr is installed
    if [[ ! -x "$desktopprBinary" ]]; then
        echo "desktoppr binary not found, exiting"
        exit 1
    fi
    # Check the dock has loaded before running
    dockStatus=$(pgrep -x Dock)
    while [[ "$dockStatus" == "" ]]; do
        sleep 2
        dockStatus=$(pgrep -x Dock)
    done
    # Set the Desktop Background for the logged in user
    runAsUser "$desktopprBinary" "$imagePath"
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        echo "Bauer Media Group image set as the Desktop Background for ${loggedInUser}"
    else
        echo "Process to set the Desktop Background for ${loggedInUser} FAILED!"
    fi
fi
exit 0