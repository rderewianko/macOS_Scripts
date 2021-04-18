#!/bin/zsh

########################################################################
#                             Uninstall Xcode                          #    
#################### Written by Phil Walker Apr 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Xcode app
appPath="/Applications/Xcode.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$appPath" ]]; then
    echo "Xcode found"
    rm -rf "$appPath"
    if [[ ! -d "$appPath" ]]; then
        echo "Xcode uninstalled successfully"
        echo "Updating inventory..."
        /usr/local/jamf/bin/jamf recon &>/dev/null
        echo "Inventory updated"
        echo "The latest version of Xcode can now be installed from Self Service"
    else
        echo "Failed to uninstall Xcode!"
        exit 1
    fi
else
    echo "Xcode not found, nothing to do"
fi
exit 0