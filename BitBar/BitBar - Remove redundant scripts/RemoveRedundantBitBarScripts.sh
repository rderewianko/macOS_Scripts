#!/bin/sh

########################################################################
#                Remove Redundant BitBar scripts                       #
############### Written by Phil Walker Jan 2019 ########################
########################################################################
#Edited Jan 2020 to remove NoMAD Login AD check

########################################################################
#                            Variables                                 #
########################################################################

# ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

########################################################################
#                            Functions                                 #
########################################################################

function checkScripts ()
{

if [[ ! -e "$BitBarAD" ]] && [[ ! -e $LaunchSysPrefs ]]; then
  echo "Redundant BitBar scripts not found, nothing to do"
  exit 0
else
  echo "Redundant BitBar scripts found"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

# Check ADPassword and LaunchSysPrefs scripts are present
checkScripts

echo "Removing redundant scripts..."

# Remove ADPassword script
rm -f "$BitBarAD"
# Remove LaunchSysPrefs script
rm -f "$LaunchSysPrefs"

# Check removal was successful
echo "Checking removal was successful"
if [[ ! -e "$BitBarAD" ]] && [[ ! -e $LaunchSysPrefs ]]; then

  echo "Redundant BitBar scripts deleted successfully"

else

  echo "Redundant BitBar scripts removal FAILED"
  exit 1

fi

exit 0
