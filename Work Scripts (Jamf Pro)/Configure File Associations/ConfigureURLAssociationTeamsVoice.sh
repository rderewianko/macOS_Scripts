#!/bin/sh

########################################################################
#         Configure URL Association for Microsoft Teams (Voice)        #
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

LSSetDefaultHandlerForURLScheme('tel', 'com.microsoft.teams')
"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No one logged in, exiting"
    exit 0
else
    echo "Setting Microsoft Teams URL associations for ${loggedInUser}..."
    sudo -u "$loggedInUser" -H python -c "$pythonScript"
    echo "Microsoft Teams now the default telephony application"
fi

exit 0