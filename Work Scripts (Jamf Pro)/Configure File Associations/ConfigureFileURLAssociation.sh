#!/bin/zsh

########################################################################
#    Configure File/URL Associations for Outlook and Self Service      #
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

# Self Service app
ssApp="/Applications/Self Service.app"
# Microsoft Outlook app
outlookApp="/Applications/Microsoft Outlook.app"
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
# if Outlook is installed set the defaults
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
exit 0