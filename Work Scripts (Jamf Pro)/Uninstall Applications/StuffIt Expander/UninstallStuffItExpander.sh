#!/bin/bash

########################################################################
#                     Uninstall StuffIt Expander                       #
################## Written by Phil Walker July 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# StuffIt Expander Application
stuffItExpander="/Applications/StuffIt Expander.app"
# StuffIt Expander v14 Application Directory
stuffItExpanderLegacy="/Applications/StuffIt"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$stuffItExpander" ]] || [[ -d "$stuffItExpanderLegacy" ]]; then
    echo "StuffIt Expander found"
    rm -rf "$stuffItExpander"
    rm -rf "$stuffItExpanderLegacy" 2>/dev/null
    if [[ ! -d "$stuffItExpander" ]] && [[ ! -d "$stuffItExpanderLegacy" ]]; then
        echo "StuffIt Expander uninstalled successfully"
    else
        echo "Failed to uninstall StuffIt Expander"
        exit 1
    fi
else
    echo "StuffIt Expander not found, nothing to do"
fi

exit 0