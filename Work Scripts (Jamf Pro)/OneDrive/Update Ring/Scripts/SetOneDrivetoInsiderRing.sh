#!/bin/bash

########################################################################
#   Set OneDrive to the Insider update ring for the logged in user     #
################ Written by Phil Walker Feb 2019 #######################
########################################################################

#Below can be set via Configuration Profile instead if using Jamf Pro

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Get current Tier value
OneDriveTier=$(su -l "$LoggedInUser" -c "defaults read com.microsoft.OneDriveUpdater Tier" 2>/dev/null)

#Update Ring Settings
UpdateRingSettings="/Users/$LoggedInUser/Library/Caches/OneDrive/UpdateRingSettings.json"

########################################################################
#                            Functions                                 #
########################################################################

function checkOneDriveTier ()
{
echo "Checking OneDrive update ring settings..."
 if [[ "$OneDriveTier" == "Insiders" ]]; then
  echo "OneDrive already set to Insider update ring, nothing to do"
  exit 0
else
  echo "Setting OneDrive to the Insiders update ring"
  killall OneDrive
  su -l "$LoggedInUser" -c "Defaults write com.microsoft.OneDriveUpdater Tier Insiders"
fi
}

function confirmCacheCleared()
{
if [[ ! -f "$UpdateRingSettings" ]]; then
  echo "Update ring cache cleared successfully"
else
  echo "Update ring cache not cleared"
  exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#echo "DEBUG: $LoggedInUser"
#echo "DEBUG: $OneDriveTier"
#echo "DEBUG: $UpdateRingSettings"

checkOneDriveTier
echo "Restarting defaults cache"
su -l "$LoggedInUser" -c "killall cfprefsd"
echo "Refreshing update rings..."
su -l "$LoggedInUser" -c "rm "$UpdateRingSettings""
confirmCacheCleared
echo "All set, launching OneDrive..."
su -l "$LoggedInUser" -c "open -a /Applications/OneDrive.app"

exit 0
