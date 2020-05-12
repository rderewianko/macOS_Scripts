#!/bin/bash

########################################################################
#        Preinstall - Bauer Media Group Desktop Background Image       #
################## Written by Phil Walker Mar 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Desktop background directory
desktopBackgrounds="/usr/local/BauerMediaGroup/Desktop/"
# Previous method launch agent
oldLaunchAgent="/Library/LaunchAgents/com.bauer.desktopwallpaper.plist"
# Previous method script
oldScript="/Library/StartupItems/setBauerDesktopWallpaper.sh"
#OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$osShort" -ge "15" ]]; then
# Clean-up previous methods content if necessary
    if [[ -e "$oldLaunchAgent" ]] || [[ -e "$oldScript" ]]; then
        echo "Removing previous methods content..."
        launchctl stop "$oldLaunchAgent" 2>/dev/null
        launchctl unload "$oldLaunchAgent" 2>/dev/null
        rm -f "$oldLaunchAgent"
        rm -f "$oldScript"
            if [[ ! -e "$oldLaunchAgent" ]] && [[ ! -e "$oldScript" ]]; then
                echo "Previous launch agent and script removed successfully"
            else
                echo "Clean-up failed, manual clean-up required"
            fi
    else
        echo "Previous method content not found"
    fi
else
    echo "Mac running ${osFull}, no clean-up required"
fi

# Remove any previous desktop background images
if [[ -d "$desktopBackgrounds" ]]; then
    rm -rf "$desktopBackgrounds"
    if [[ ! -d "$desktopBackgrounds" ]]; then
        echo "Existing desktop background images directory removed"
    else
        echo "Directory removal failed, manual removal may be required"
    fi
else
    echo "Existing desktop background images directory not found"
fi

exit 0
