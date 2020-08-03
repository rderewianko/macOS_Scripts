#!/bin/bash

########################################################################
#                     Uninstall StuffIt Expander                       #
################## Written by Phil Walker July 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# StuffIt Expander Application Directory
stuffItExpander="/Applications/StuffIt"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$stuffItExpander" ]]; then
    echo "StuffIt Expander found"
    rm -rf "$stuffItExpander"
    if [[ ! -d "$stuffItExpander" ]]; then
        echo "StuffIt Expander uninstalled successfully"
    else
        echo "Failed to uninstall StuffIt Expander"
        exit 1
    fi
else
    echo "StuffIt Expander not found, nothing to do"
fi

exit 0