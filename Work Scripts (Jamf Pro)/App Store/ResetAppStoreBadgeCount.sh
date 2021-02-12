#!/bin/zsh

########################################################################
#                  Reset Badge Count for the App Store                 #
##################### Written by Phil Walker Dec 2020 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# App Store plists
appStorePlist="/Users/${loggedInUser}/Library/Preferences/com.apple.appstore.plist"
apStoredPlist="/Users/${loggedInUser}/Library/Preferences/com.apple.appstored.plist"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, exiting..."
    exit 0
else
    if [[ -f "$appStorePlist" || -f "$apStoredPlist" ]]; then
        sudo -u "$loggedInUser" defaults delete com.apple.appstore appStoreBadgeCount >/dev/null 2>&1
        sudo -u "$loggedInUser" defaults delete com.apple.appstored BadgeCount >/dev/null 2>&1
    fi
fi