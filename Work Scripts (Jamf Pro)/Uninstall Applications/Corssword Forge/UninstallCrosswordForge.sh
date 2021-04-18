#!/bin/zsh

########################################################################
#                     Uninstall Crossword Forge                        #
################## Written by Phil Walker Apr 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Crossword Forge Application
crosswordForge="/Applications/Crossword Forge.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$crosswordForge" ]]; then
    echo "Crossword Forge found"
    rm -rf "$crosswordForge"
    if [[ ! -d "$crosswordForge" ]]; then
        echo "Crossword Forge uninstalled successfully"
    else
        echo "Failed to uninstall Crossword Forge"
        exit 1
    fi
else
    echo "Crossword Forge not found, nothing to do"
fi
exit 0