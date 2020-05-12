#!/bin/bash

########################################################################
#                 Open the EraseInstall application                    #
################### Written by Phil Walker Apr 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

loggedInUser=$(stat -f %Su /dev/console)
eraseInstall="/Applications/Utilities/EraseInstall.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$eraseInstall" ]]; then
    su -l "$loggedInUser" -c "open -F /Applications/Utilities/EraseInstall.app"
    if [[ $(ps -Ac | grep -i "EraseInstall") != "" ]]; then
        echo "EraseInstall application opened"
    else
        echo "Failed to open the EraseInstall application"
        exit 1
    fi
else
    echo "EraseInstall application not found!"
    exit 1
fi

exit 0

    