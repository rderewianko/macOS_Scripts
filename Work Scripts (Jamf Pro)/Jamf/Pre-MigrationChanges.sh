#!/bin/zsh

########################################################################
#                       Pre-Migration Changes                          #
################## Written by Phil Walker Apr 2021 #####################
########################################################################
# Remove the MDM profile
# Disable Notifications for Sophos Endpoint and Jamf Connect
# Disable Jamf Connect Welcome Screen

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Notification Center preferences plist for the logged in user
notificationPlist="/Users/${loggedInUser}/Library/Preferences/com.apple.ncprefs.plist"
# Get total bundles
totalBundles=$(/usr/libexec/PlistBuddy -c "Print :apps" "${notificationPlist}" | grep -c "bundle-id")
# Jamf binary
jamfBinary="/usr/local/jamf/bin/jamf"
# Managed preferences
notificationManagedPrefs="/Library/Managed Preferences/com.apple.notificationsettings.plist"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
    # Remove the MDM profile only
    "$jamfBinary" removeMdmprofile
else
    echo "${loggedInUser} logged in, setting user preferences before migration to Jamf Cloud..."
    # Disable the welcome screen for Jamf Connect - user level
    runAsUser defaults write com.jamf.connect ShowWelcomeWindow -bool FALSE
    prefCheck=$(runAsUser defaults read com.jamf.connect ShowWelcomeWindow)
    if [[ "$prefCheck" == "0" ]] || [[ "$prefCheck" == "false" ]]; then
        echo "Jamf Connect's welcome window disabled"
    else
        echo "Failed to disable Jamf Connect's welcome window!"
    fi
    # Disable notifications for Sophos Endpoint and Jamf Connect - user level
    for ((app=1; app<=${totalBundles}; app++)); do
        appBundleID=$(/usr/libexec/PlistBuddy -c "Print apps:${app}:bundle-id" "${notificationPlist}" 2>/dev/null)
        if [[ "$appBundleID" == "com.sophos.endpoint.uiserver" ]]; then
            runAsUser /usr/libexec/PlistBuddy -c "Set :apps:${app}:flags 276832270" "${notificationPlist}"
            sophosCheck=$(/usr/libexec/PlistBuddy -c "Print :apps:${app}:flags" "${notificationPlist}")
            if [[ "$sophosCheck" == "276832270" ]]; then
                echo "Notifications disabled for Sophos Endpoint"
            else
                echo "Failed to disable notifications for Sophos Endpoint!"
            fi
        elif [[ "$appBundleID" == "com.jamf.connect" ]]; then
            runAsUser /usr/libexec/PlistBuddy -c "Set :apps:${app}:flags 276832270" "${notificationPlist}"
            nomadCheck=$(/usr/libexec/PlistBuddy -c "Print :apps:${app}:flags" "${notificationPlist}")
            if [[ "$nomadCheck" == "276832270" ]]; then
                echo "Notifications disabled for Jamf Connect"
            else
                echo "Failed to disable notifications for Jamf Connect!"
            fi
        fi
    done
    # Remove the MDM profile
    "$jamfBinary" removeMdmprofile
    # Restart notification center
    killall sighup usernoted
    killall sighup NotificationCenter
fi
# Allow time for the Configuration Profiles to be removed before migrating to Jamf Cloud
sleep 30
exit 0