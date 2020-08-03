#!/bin/bash

########################################################################
#                      Uninstall FileMaker Pro 11                      #
################### Written by Phil Walker July 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# FileMaker Pro 11 App Directory
filemakerPro="/Applications/FileMaker Pro 11"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$filemakerPro" ]]; then
    # Remove the app only, no user preferences
    rm -rf "$filemakerPro"
    if [[ ! -d "$filemakerPro" ]]; then
        echo "FileMaker Pro 11 successfully uninstalled"
    else
        echo "Failed to uninstall FileMaker Pro 11"
        exit 1
    fi
else
    echo "FileMaker Pro 11 not found, nothing to do"
fi

exit 0