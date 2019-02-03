#!/bin/bash

########################################################################
# Set OneDrive to Insiders Ring update channel for the logged in user  #
################ Written by Phil Walker Dec 2018 #######################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Get the logged in user group ID
LoggedInUserGroupID=$(dscl . read /Users/$LoggedInUser | grep "PrimaryGroupID" | awk '{print $2}')
echo "DEBUG : $LoggedInUserGroupID"

if [[ "$LoggedInUserGroupID" -eq "1116074086" ]]; then
  LoggedInUserGroup="BAUER-UK\Domain Users"
else
  LoggedInUserGroup="staff"
fi

########################################################################
#                         Script starts here                           #
########################################################################

echo "Setting OneDrive to the Insiders Ring update channel"
Defaults write /Users/$LoggedInUser/Library/Preferences/com.microsoft.OneDriveUpdater Tier Insiders
chown "$LoggedInUser":"$LoggedInUserGroupID" /Users/$LoggedInUser/Library/Preferences/com.microsoft.OneDriveUpdater.plist
chmod 600 /Users/$LoggedInUser/Library/Preferences/com.microsoft.OneDriveUpdater.plist
echo "Restarting Defaults Cache"
killall cfprefsd
echo "Refreshing Update Rings"
rm /Users/$LoggedInUser/Library/Caches/OneDrive/UpdateRingSettings.json
echo "All set!"

exit 0
