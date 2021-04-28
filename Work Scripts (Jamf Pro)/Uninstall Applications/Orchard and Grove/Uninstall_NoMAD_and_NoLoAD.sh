#!/bin/zsh

########################################################################
#                Uninstall NoMAD and NoMAD Login AD                    #
################## Written by Phil Walker Apr 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# NoMAD content
nomadApp="/Applications/NoMAD.app"
nomadLaunchAgent="/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist"
nomadManagedPrefs="/Library/Managed Preferences/com.trusourcelabs.NoMAD.plist"
nomadPrefs="/Library/Preferences/com.trusourcelabs.NoMAD.plist"
nomadUserPrefs="/Users/${loggedInUser}/Library/Preferences/com.trusourcelabs.NoMAD.plist"
# NoMAD Login AD content  
noloBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
noloManagedPrefs="/Library/Managed Preferences/menu.nomad.login.ad.plist"
noloPrefs="/Library/Preferences/menu.nomad.login.ad.plist"
noloUserPrefs="/Users/${loggedInUser}/Library/Preferences/menu.nomad.login.ad.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Reset login window to default
if [[ -e "/usr/local/bin/authchanger" ]]; then
    /usr/local/bin/authchanger -reset
    echo "Login window reset back to default settings"
else
    echo "Authchange binary not found, exiting..."
    exit 1
fi
# Uninstall/Delete NoMAD
if [[ -d "$nomadApp" ]]; then
    echo "Uninstalling/Deleting all NoMAD content..."
    # Bootout and remove the Launch Agent
    if [[ -f "$nomadLaunchAgent" ]]; then
        launchctl bootout gui/"$loggedInUserID" "$nomadLaunchAgent" &>/dev/null
        rm -f "$nomadLaunchAgent" &>/dev/null
        if [[ ! -f "$nomadLaunchAgent" ]]; then
            echo "NoMAD Launch Agent booted out and deleted"
        else
            echo "Failed to bootout and delete the NoMAD Launch Agent"
            exit 1
        fi
    else
        echo "NoMAD Launch Agent not found"
    fi
    # Uninstall the app
    rm -rf "$nomadApp"
    if [[ ! -d "$nomadApp" ]]; then
        echo "Uninstalled NoMAD application"
    else
        echo "Failed to uninstall NoMAD application"
    fi
    # Delete preferences
    if [[ -f "$nomadManagedPrefs" ]] || [[ -f "$nomadPrefs" ]] || [[ -f "$nomadUserPrefs" ]]; then
        rm -f "$nomadManagedPrefs" 2>/dev/null
        rm -f "$nomadPrefs" 2>/dev/null
        rm -f "$nomadUserPrefs" 2>/dev/null
        if [[ ! -f "$nomadManagedPrefs" ]] && [[ ! -f "$nomadPrefs" ]] || [[ ! -f "$nomadUserPrefs" ]]; then
            echo "NoMAD preferences deleted"
        fi
    fi
else
    echo "NoMAD application not found, nothing to do"
fi
# Uninstall/Delete NoMAD Login AD content
if [[ -d "$noloBundle" ]]; then
    echo "Uninstalling/Deleting all NoMAD Login AD content..."
    # Uninstall the bundle
    rm -rf "$noloBundle"
    if [[ ! -d "$noloBundle" ]]; then
        echo "Uninstalled NoMAD Login AD bundle"
    else
        echo "Failed to uninstall NoMAD Login AD bundle"
    fi
    # Delete preferences
    if [[ -f "$noloManagedPrefs" ]] || [[ -f "$noloPrefs" ]] || [[ -f "$noloUserPrefs" ]]; then
        rm -f "$noloManagedPrefs" 2>/dev/null
        rm -f "$noloPrefs" 2>/dev/null
        rm -f "$noloUserPrefs" 2>/dev/null
        if [[ ! -f "$noloManagedPrefs" ]] && [[ ! -f "$noloPrefs" ]] || [[ ! -f "$noloUserPrefs" ]]; then
            echo "NoMAD Login AD preferences deleted"
        fi
    fi
else
    echo "NoMAD Login AD bundle not found, nothing to do"
fi
exit 0