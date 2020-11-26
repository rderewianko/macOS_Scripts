#!/bin/zsh

########################################################################
#             Remove all Pro Audio User Template Content               #
################## Written by Phil Walker Nov 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Mac model
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# OS Version
osVersion=$(sw_vers -productVersion)
# Minimum required OS version
minReqOS="10.15"
# User Template path
userTemplate="/Library/User Template/English.lproj"
# User Template Documents
utDocuments="${userTemplate}/Documents"
# User Template PT Prefs
utProToolsPrefs="${userTemplate}/Library/Application Support/FB360 Spatial Workstation"
# User Template UAD Prefs
utUADPrefs="${userTemplate}/Library/Preferences/Universal Audio"

########################################################################
#                         Script starts here                           #
########################################################################

# Check the OS requirements are met
autoload is-at-least
if is-at-least "$minReqOS" "$osVersion"; then
    echo "$macModelFull running ${osVersion}, checking for Pro Audio content in the User Template..."
else
    echo "$macModelFull running ${osVersion}, macOS Catalina or later required"
    echo "Exiting...."
    exit 0
fi
# If found remove all Pro Audio Documents directory from the User Template
if [[ -d "$utDocuments" ]]; then
    echo "Pro Audio Documents directory found in the User Template"
    rm -rf "$utDocuments"
    if [[ ! -d "$utDocuments" ]]; then
        echo "Successfully removed the Pro Audio Documents directory from the User Template"
    else
        echo "Failed to remove the Pro Audio Documents directory from the User Template"
        echo "Needs investigating as this can cause new user account profile creation issues"
        exit 1
    fi
    else
    echo "Pro Audio Documents directory not found in the User Template"
fi
# If found remove all Pro Audio Preferences from the User Template
if [[ -d "$utProToolsPrefs" ]]; then
    echo "Pro Tools Preferences found in the User Template"
    rm -rf "$utProToolsPrefs"
    if [[ ! -d "$utProToolsPrefs" ]]; then
        echo "Successfully removed the Pro Tools Preferences from the User Template"
    else
        echo "Failed to remove the Pro Tools Preferences from the User Template"
    fi
else
    echo "Pro Tools Preferences not found in the User Template"
fi
# If found remove all UAD Preferences from the User Template
if [[ -d "$utUADPrefs" ]]; then
    echo "Pro Tools Preferences found in the User Template"
    rm -rf "$utUADPrefs"
    if [[ ! -d "$utUADPrefs" ]]; then
        echo "Successfully removed the Pro Tools Preferences from the User Template"
    else
        echo "Failed to remove the Pro Tools Preferences from the User Template"
    fi
else
    echo "Pro Tools Preferences not found in the User Template"
fi
exit 0