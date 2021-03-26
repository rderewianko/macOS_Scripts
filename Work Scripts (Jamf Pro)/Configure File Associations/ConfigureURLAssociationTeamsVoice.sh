#!/bin/zsh

########################################################################
#         Configure URL Association for Microsoft Teams (Voice)        #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################
# Edit Feb 2021

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
# Microsoft Teams app
teamsApp="/Applications/Microsoft Teams.app"
# Pyhton script to use LaunchServices to set defaults for Teams
teamsDefaults="
import os
import sys

from LaunchServices import *

LSSetDefaultHandlerForURLScheme('tel', 'com.microsoft.teams')
"

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

# If Teams is installed set the defaults
if [[ -d "$teamsApp" ]]; then
    echo "Setting Microsoft Teams URL associations for ${loggedInUser}..."
    runAsUser -H python -c "$teamsDefaults"
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        echo "Microsoft Teams now the default phone application"
    else
        echo "Failed to set Microsoft Teams default URL associations for ${loggedInUser}"
    fi
else
    echo "Microsoft Teams not found, default associations not set"
fi
exit 0