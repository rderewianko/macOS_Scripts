#!/bin/bash

########################################################################
#    Configure File/URL Associations for Outlook and Self Service      #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

# Pyhton script to use LaunchServices to set defaults
pythonScript="
import os
import sys

from LaunchServices import *

LSSetDefaultHandlerForURLScheme('selfservice', 'com.jamfsoftware.selfservice')
LSSetDefaultHandlerForURLScheme('mailto', 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.apple.mail.email', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('public.vcard', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.apple.ical.ics', 0x00000002, 'com.microsoft.Outlook')
LSSetDefaultRoleHandlerForContentType('com.microsoft.outlook16.icalendar', 0x00000002, 'com.microsoft.Outlook')
"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No one logged in, exiting"
    exit 0
else
    echo "Setting Microsoft Outlook file/URL associations for ${loggedInUser}..."
    sudo -u "$loggedInUser" -H python -c "$pythonScript"
    if [[ "$?" == "0" ]]; then
        echo "Microsoft Outlook now the default mail and calendar application"
    else
        echo "Failed to set default file and URL associations for ${loggedInUser}"
    fi
fi

exit 0