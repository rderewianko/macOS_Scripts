#!/bin/bash

########################################################################
#                     Uninstall Avaya Softphone                        #
################## Written by Phil Walker Oct 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Avaya Softphone Application
avayaSoftphone="/Applications/Softphone.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$avayaSoftphone" ]]; then
    echo "Avaya Softphone found"
    rm -rf "$avayaSoftphone"
    if [[ ! -d "$avayaSoftphone" ]]; then
        echo "Avaya Softphone uninstalled successfully"
    else
        echo "Failed to uninstall Avaya Softphone"
        exit 1
    fi
else
    echo "Avaya Softphone not found, nothing to do"
fi

exit 0