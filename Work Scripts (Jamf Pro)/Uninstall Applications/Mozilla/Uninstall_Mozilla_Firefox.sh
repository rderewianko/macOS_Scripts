#!/bin/bash

########################################################################
#                      Uninstall Mozilla Firefox                       #
################### Written by Phil Walker June 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Firefox app
firefoxApp="/Applications/Firefox.app"
# Firefox process ID
firefoxPID=$(pgrep "firefox")

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$firefoxApp" ]]; then
    # Make sure Firefox is not in use
    if [[ "$firefoxPID" == "" ]]; then
        echo "Firefox installed and not in use"
        # Remove the app only, no user preferences
        rm -rf "$firefoxApp"
        if [[ ! -d "$firefoxApp" ]]; then
            echo "Firefox successfully uninstalled"
        else
            echo "Failed to uninstall Firefox"
            exit 1
        fi
    else
        # Data in SNOW must be incorrect as the app is clearly used
        echo "Firefox installed and in use so will not be uninstalled"
    fi
else
    echo "Firefox not found, nothing to do"
fi

exit 0