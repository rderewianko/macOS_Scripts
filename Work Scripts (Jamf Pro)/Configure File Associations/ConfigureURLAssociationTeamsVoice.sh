#!/bin/zsh

########################################################################
#         Configure URL Association for Microsoft Teams (Voice)        #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################
# Edit Feb 2021

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
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

# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    exit 0
else
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
fi
exit 0