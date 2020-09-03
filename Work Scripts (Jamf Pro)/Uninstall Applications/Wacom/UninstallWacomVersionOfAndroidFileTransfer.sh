#!/bin/bash

########################################################################
#       Uninstall Wacom Tablet Version of Android File Transfer        #
################### Written by Phil Walker Aug 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# AFT application
wacomAFT="/Applications/Wacom Tablet.localized/Android File Transfer.app"

########################################################################
#                         Script starts here                           #
########################################################################


if [[ -d "$wacomAFT" ]]; then
    rm -rf "$wacomAFT"
    if [[ ! -d "$wacomAFT" ]]; then
        echo "Wacom Tablet version of Android File Transfer uninstalled successfully"
    else
        echo "Failed to uninstall the Wacom Tablet version of Android File Transfer"
        echo "Manual cleanup requried as the application is 32-bit"
    fi
else
    echo "Wacom Tablet version of Android File Transfer not found"
fi