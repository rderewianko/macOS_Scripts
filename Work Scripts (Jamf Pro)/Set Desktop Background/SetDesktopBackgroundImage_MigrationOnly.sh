#!/bin/zsh

########################################################################
#           Set Bauer Media Group Desktop Background Image             #
################## Written by Phil Walker Mar 2020 #####################
########################################################################

# Pre-Reqs: 
# 1. desktoppr (https://github.com/scriptingosx/desktoppr)
# 2. Desktop Background image of your choice
# Command to set Desktop Background must be run as the user

# Edit for migration to Jamf Cloud. Background will only be changed during provisioning

# Before any variables are defined or any actions are taken, complete a few checks
echo "Checking all requirements are met..."
# Check a normal user is logged in
loggedInUser=$(stat -f %Su /dev/console)
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    while [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; do
        sleep 2
        loggedInUser=$(stat -f %Su /dev/console)
    done
fi
# Check Finder is running
finderProcess=$(pgrep -x "Finder")
until [[ "$finderProcess" != "" ]]; do
    sleep 2
    finderProcess=$(pgrep -x "Finder")
done
# Check the Dock is running
dockProcess=$(pgrep -x "Dock")
until [[ "$dockProcess" != "" ]]; do
    sleep 2
    dockProcess=$(pgrep -x "Dock")
done
echo "All requirements met"

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# desktoppr binary
desktopprBinary="/usr/local/bin/desktoppr"
# Desktop Background Image path
imagePath="/usr/local/BauerMediaGroup/Desktop/BauerMediaGroupDesktop.heic"
# DEPNotify process
depNotify=$(pgrep "DEPNotify")

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
if [[ "$depNotify" != "" ]]; then
    # Set the Desktop Background for the logged in user
    runAsUser "$desktopprBinary" "$imagePath"
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        echo "Bauer Media Group image set as the Desktop Background for ${loggedInUser}"
    else
        echo "Process to set the Desktop Background for ${loggedInUser} FAILED!"
    fi
else
    echo "Mac not currently being provisioned"
    echo "No changes will be made to ${loggedInUser}'s desktop background"
fi
exit 0