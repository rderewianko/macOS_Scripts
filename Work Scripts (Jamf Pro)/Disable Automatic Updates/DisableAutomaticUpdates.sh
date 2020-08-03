#!/bin/bash

########################################################################
#         Disable Automatic Software Updates (macOS Mojave Only)       #
################### Written by Phil Walker Apr 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')
# Software Update plist
plistPath="/Library/Preferences/com.apple.SoftwareUpdate.plist"

########################################################################
#                            Functions                                 #
########################################################################

function postCheck ()
{
autoCheck=$(/usr/bin/defaults read "$plistPath" AutomaticCheckEnabled)
if [[ "$autoCheck" == "0" ]] || [[ "$autoCheck" == "false" ]]; then
    echo "Automatic update background check disabled"
else
    echo "Automatic update background check enabled"
    exit 1
fi
autoDownload=$(/usr/bin/defaults read "$plistPath" AutomaticDownload)
if [[ "$autoDownload" == "0" ]] || [[ "$autoDownload" == "false" ]]; then
    echo "Automatic update download disabled"
else
    echo "Automatic update download enabled"
    exit 1
fi
autoInstallConfig=$(/usr/bin/defaults read "$plistPath" ConfigDataInstall)
if [[ "$autoInstallConfig" == "0" ]] || [[ "$autoInstallConfig" == "false" ]]; then
    echo "Automatic install of config data updates disabled"
else
    echo "Automatic install of config data updates enabled"
    exit 1
fi
autoInstallCritical=$(/usr/bin/defaults read "$plistPath" CriticalUpdateInstall)
if [[ "$autoInstallCritical" == "0" ]] || [[ "$autoInstallCritical" == "false" ]]; then
    echo "Automatic install of critical updates disabled"
else
    echo "Automatic install of critical updates enabled"
    exit 1
fi
autoInstallMacOS=$(/usr/bin/defaults read "$plistPath" AutomaticallyInstallMacOSUpdates)
if [[ "$autoInstallMacOS" == "0" ]] || [[ "$autoInstallMacOS" == "false" ]]; then
    echo "Automatic install of macOS updates disabled"
else
    echo "Automatic install of macOS enabled"
    exit 1
fi
# check the Catalina upgrade has been ignored successfully
postCheck=$(softwareupdate --ignore | grep -v "Ignored updates:" | sed -e 's/[()]//g' | awk NF | xargs)
if [[ "$postCheck" == "macOS Catalina" ]]; then
    echo "Catalina upgrade via software update now blocked"
else
    echo "Catalina upgrade still available via software update, admin rights required to complete the install!"
fi
}

function removeBadgeAppIcon ()
{
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No one is home, cannot remove badge app icon"
else
    sysPrefsDockItem=$(su -l "$loggedInUser" -c "defaults read com.apple.dock" | grep "System%20Preferences.app")
    if [[ "$sysPrefsDockItem" != "" ]]; then
        sudo -u "$loggedInUser" defaults write com.apple.systempreferences AttentionPrefBundleIDs 0
        killall Dock
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm OS version is Mojave
if [[ "$osShort" -eq 14 ]]; then
    # Disable automatic background check for macOS software updates
    /usr/bin/defaults write "$plistPath" AutomaticCheckEnabled -bool false
    # Disable automatic download of macOS software updates
    /usr/bin/defaults write "$plistPath" AutomaticDownload -bool false
    # Disable automatic installation of macOS updates
    /usr/bin/defaults write "$plistPath" AutomaticallyInstallMacOSUpdates -bool false
    # Disable automatic download and installation of XProtect, MRT and Gatekeeper updates
    /usr/bin/defaults write "$plistPath" ConfigDataInstall -bool false
    # Disable automatic download and installation of automatic security updates
    /usr/bin/defaults write "$plistPath" CriticalUpdateInstall -bool false
    # Ignore the Catalina update
    /usr/sbin/softwareupdate --ignore "macOS Catalina" >/dev/null 2>&1
    # Check all settings have been applied successfully
    postCheck
else
    echo "Mac running ${osFull}, no changes required"
fi

exit 0