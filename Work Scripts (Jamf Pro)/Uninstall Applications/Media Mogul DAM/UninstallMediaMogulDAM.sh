#!/bin/bash

########################################################################
#                      Uninstall Media Mogul DAM                       #
################## Written by Phil Walker July 2020 ####################
########################################################################
# 32 bit app that is no longer in use

########################################################################
#                            Variables                                 #
########################################################################

# Media Mogul DAM Application
mediaMogulDAM="/Applications/Media Mogul DAM.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$mediaMogulDAM" ]]; then
    echo "Media Mogul DAM found"
    rm -rf "$mediaMogulDAM"
    if [[ ! -d "$mediaMogulDAM" ]]; then
        echo "Media Mogul DAM uninstalled successfully"
    else
        echo "Failed to uninstall Media Mogul DAM"
        exit 1
    fi
else
    echo "Media Mogul DAM not found, nothing to do"
fi

exit 0