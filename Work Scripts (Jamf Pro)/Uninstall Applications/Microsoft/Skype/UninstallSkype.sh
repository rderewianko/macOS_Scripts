#!/bin/bash

########################################################################
#                          Uninstall Skype                             #
################## Written by Phil Walker Apr 2020 #####################
########################################################################

if [[ -d "/Applications/Skype.app" ]]; then
    echo "Skype found"
    rm -rf "/Applications/Skype.app"
    if [[ ! -d "/Applications/Skype.app" ]]; then
        echo "Skype removed successfully"
    else
        echo "Removal FAILED!"
        exit 1
    fi
else
    echo "Skype not found, nothing to do"
fi

exit 0