#!/bin/zsh

########################################################################
#                 Disable Automatic Software Updates                   #
################### Written by Phil Walker Apr 2020 ####################
########################################################################
# Edit Nov 12th 2020

########################################################################
#                            Variables                                 #
########################################################################

# OS Version
osVersion=$(sw_vers -productVersion)
# Mac model
macModel=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# macOS Big Sur base version
bigSur="11"
# Software Update plist
suPlist="/Library/Preferences/com.apple.SoftwareUpdate.plist"
# App Store plist
masPlist="/Library/Preferences/com.apple.commerce.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm OS version is Catalina or earlier
autoload is-at-least
if ! is-at-least "$bigSur" "$osVersion"; then
    echo "${macModel} running ${osVersion}, checking update settings..."
    # Automatic background check
    autoCheck=$(/usr/bin/defaults read "$suPlist" AutomaticCheckEnabled 2>/dev/null)
    if [[ "$autoCheck" == "0" ]] || [[ "$autoCheck" == "false" ]]; then
        echo "Automatic update background check already disabled"
    else
        # Disable automatic background check for macOS software updates
        defaults write "$suPlist" AutomaticCheckEnabled -bool false
        # re-populate the variable
        autoCheck=$(/usr/bin/defaults read "$suPlist" AutomaticCheckEnabled)
        if [[ "$autoCheck" == "0" ]] || [[ "$autoCheck" == "false" ]]; then
            echo "Automatic update background check now disabled"
        else
            echo "Automatic update background check still enabled"
            exit 1
        fi
    fi
    # Automatic download
    autoDownload=$(/usr/bin/defaults read "$suPlist" AutomaticDownload 2>/dev/null)
    if [[ "$autoDownload" == "0" ]] || [[ "$autoDownload" == "false" ]]; then
        echo "Automatic update download already disabled"
    else
        # Disable automatic download of macOS software updates
        defaults write "$suPlist" AutomaticDownload -bool false
        # re-populate variable
        autoDownload=$(/usr/bin/defaults read "$suPlist" AutomaticDownload)
        if [[ "$autoDownload" == "0" ]] || [[ "$autoDownload" == "false" ]]; then
            echo "Automatic update download now disabled"
        else
            echo "Automatic update download still enabled"
            exit 1
        fi
    fi
    # Automatic macOS update install
    autoInstallMacOS=$(/usr/bin/defaults read "$suPlist" AutomaticallyInstallMacOSUpdates 2>/dev/null)
    if [[ "$autoInstallMacOS" == "0" ]] || [[ "$autoInstallMacOS" == "false" ]]; then
        echo "Automatic install of macOS updates already disabled"
    else
        # Disable automatic installation of macOS updates
        defaults write "$suPlist" AutomaticallyInstallMacOSUpdates -bool false
        # re-populate variable
        autoInstallMacOS=$(/usr/bin/defaults read "$suPlist" AutomaticallyInstallMacOSUpdates)
        if [[ "$autoInstallMacOS" == "0" ]] || [[ "$autoInstallMacOS" == "false" ]]; then
            echo "Automatic install of macOS updates now disabled"
        else
            echo "Automatic install of macOS still enabled"
            exit 1
        fi
    fi
    # Automatic download and install of config updates
    autoInstallConfig=$(/usr/bin/defaults read "$suPlist" ConfigDataInstall 2>/dev/null)
    if [[ "$autoInstallConfig" == "0" ]] || [[ "$autoInstallConfig" == "false" ]]; then
        echo "Automatic install of config data updates already disabled"
    else
        # Disable automatic download and installation of XProtect, MRT and Gatekeeper updates
        defaults write "$suPlist" ConfigDataInstall -bool false
        # re-populate variable
        autoInstallConfig=$(/usr/bin/defaults read "$suPlist" ConfigDataInstall)
        if [[ "$autoInstallConfig" == "0" ]] || [[ "$autoInstallConfig" == "false" ]]; then
            echo "Automatic install of config data updates now disabled"
        else
            echo "Automatic install of config data updates still  enabled"
            exit 1
        fi
    fi
    # Automatic download and install of critical updates
    autoInstallCritical=$(/usr/bin/defaults read "$suPlist" CriticalUpdateInstall 2>/dev/null)
    if [[ "$autoInstallCritical" == "0" ]] || [[ "$autoInstallCritical" == "false" ]]; then
        echo "Automatic install of critical updates already disabled"
    else
        # Disable automatic download and installation of automatic security updates
        defaults write "$suPlist" CriticalUpdateInstall -bool false
        # re-populate variable
        autoInstallCritical=$(/usr/bin/defaults read "$suPlist" CriticalUpdateInstall)
        if [[ "$autoInstallCritical" == "0" ]] || [[ "$autoInstallCritical" == "false" ]]; then
            echo "Automatic install of critical updates now disabled"
        else
            echo "Automatic install of critical updates still enabled"
            exit 1
        fi
    fi
    # Automatic app updates from the App Store
    autoInstallMAS=$(/usr/bin/defaults read "$masPlist" AutoUpdate 2>/dev/null)
    if [[ "$autoInstallMAS" == "0" ]] || [[ "$autoInstallMAS" == "false" ]]; then
        echo "Automatic install of app updates from the App Store already disabled"
    else
        # Disable automatic install of app updates from the App Store
        defaults write "$masPlist" AutoUpdate -bool false
        # re-populate variable
        autoInstallMAS=$(/usr/bin/defaults read "$masPlist" AutoUpdate 2>/dev/null)
        if [[ "$autoInstallMAS" == "0" ]] || [[ "$autoInstallMAS" == "false" ]]; then
            echo "Automatic install of app updates from the App Store now disabled"
        else
            echo "Automatic install of app updates from the App Store still enabled"
            exit 1
        fi
    fi
else
    echo "Mac running ${osVersion}, no changes required"
fi
exit 0