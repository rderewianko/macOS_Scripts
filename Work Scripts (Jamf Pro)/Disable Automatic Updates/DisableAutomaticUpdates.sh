#!/bin/zsh

########################################################################
#        Disable Automatic Software Updates (Pre Big Sur Only)         #
################### Written by Phil Walker Apr 2020 ####################
########################################################################
# Edit Nov 12th 2020

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# OS Version
osVersion=$(sw_vers -productVersion)
# macOS Big Sur base version
bigSur="11"
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
# check the Big Sur upgrade has been ignored successfully
postCheck=$(softwareupdate --ignore | grep -v "Ignored updates:" | sed -n 2p | xargs)
if [[ "$postCheck" =~ "macOS Big Sur" ]]; then
    echo "Big Sur upgrade via software update now blocked"
else
    echo "Big Sur upgrade still available via software update, admin rights still required to complete the install!"
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
        echo "Badge app icon will be gone the next time the dock is relaunched"
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm OS version is Catalina or earlier
autoload is-at-least
if ! is-at-least "$bigSur" "$osVersion"; then
    echo "Mac running ${osVersion}, disabling auto updates and ignoring Big Sur..."
    # Disable automatic background check for macOS software updates
    defaults write "$plistPath" AutomaticCheckEnabled -bool false
    # Disable automatic download of macOS software updates
    defaults write "$plistPath" AutomaticDownload -bool false
    # Disable automatic installation of macOS updates
    defaults write "$plistPath" AutomaticallyInstallMacOSUpdates -bool false
    # Disable automatic download and installation of XProtect, MRT and Gatekeeper updates
    defaults write "$plistPath" ConfigDataInstall -bool false
    # Disable automatic download and installation of automatic security updates
    defaults write "$plistPath" CriticalUpdateInstall -bool false
    # Ignore the Big Sur update
    softwareupdate --reset-ignored >/dev/null 2>&1
    softwareupdate --ignore "macOS Big Sur" >/dev/null 2>&1
    # Check all settings have been applied successfully
    postCheck
    # Remove the badge icon
    removeBadgeAppIcon
else
    echo "Mac running ${osVersion}, no changes required"
fi
exit 0