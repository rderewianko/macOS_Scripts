#!/bin/zsh

########################################################################
# Configure File/URL Associations for Outlook, Teams and Self Service  #
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
# Self Service app
ssApp="/Applications/Self Service.app"
# Microsoft Outlook app
outlookApp="/Applications/Microsoft Outlook.app"
# Microsoft Teams app
teamsApp="/Applications/Microsoft Teams.app"
# Pyhton script to use LaunchServices to set defaults for Self Service
ssDefaults="
import os
import sys

from LaunchServices import *

LSSetDefaultHandlerForURLScheme('selfservice', 'com.jamfsoftware.selfservice')
"
# Pyhton script to use LaunchServices to set defaults for Outlook
outlookDefaults="
import os
import sys

from LaunchServices import *

LSSetDefaultHandlerForURLScheme('mailto', 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.apple.mail.email', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('public.vcard', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.apple.ical.ics', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.microsoft.outlook16.icalendar', 0x00000002, 'com.microsoft.Outlook')
"

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
    # If Self Service is installed set the defaults
    if [[ -d "$ssApp" ]]; then
        echo "Setting Self Service URL associations for ${loggedInUser}..."
        runAsUser -H python -c "$ssDefaults"
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Self Service URL association set"
        else
            echo "Failed to set Self Service URL associations for ${loggedInUser}"
        fi
    else
        echo "Self Service not found, default associations not set"
    fi
    # If Outlook is installed set the defaults
    if [[ -d "$outlookApp" ]]; then
        echo "Setting Microsoft Outlook file/URL associations for ${loggedInUser}..."
        runAsUser -H python -c "$outlookDefaults"
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Microsoft Outlook now the default mail and calendar application"
        else
            echo "Failed to set default file and URL associations for ${loggedInUser}"
        fi
    else
        echo "Microsoft Outlook not found, default associations not set"
    fi
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