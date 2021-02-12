#!/bin/zsh

########################################################################
#     Remove All Open Skype for Business After User Login Content      #
################### written by Phil Walker Jan 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Launch Agent
launchAgent="/Library/LaunchAgents/com.bauer.OpenSkypeForBusinessAfterUserLogin.plist"
# Script
startupItem="/Library/StartupItems/OpenSkypeForBusinessAfterUserLogin.sh"

########################################################################
#                         Script starts here                           #
########################################################################

echo "Checking for the 'Open Skype for Business After User Login' content..."
if [[ -f "$launchAgent" || -f "$startupItem" ]]; then
    echo "Content Found"
    rm -f "$launchAgent" 2>/dev/null
    rm -f "$startupItem" 2>/dev/null
    if [[ ! -f "$launchAgent" && ! -f "$startupItem" ]]; then
        echo "All content removed successfully"
    else
        echo "Failed to remove content!"
        exit 1
    fi
else
    echo "Content not found, nothing to do"
fi
exit 0