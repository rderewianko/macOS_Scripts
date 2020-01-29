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

if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then
  echo "ADPassword and LaunchSysPrefs scripts not found, nothing to do"
  exit 0
else
  echo "ADPassword and LaunchSysPrefs scripts found, both will be removed"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

# Check ADPassword and LaunchSysPrefs scripts are present
checkScripts

echo "Removing ADPassword and LaunchSysPrefs scripts..."

# Remove ADPassword script
rm -f "$BitBarAD"
# Remove LaunchSysPrefs script
rm -f "$LaunchSysPrefs"

# Check removal was successful
echo "Checking removal was successful"
if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then

  echo "ADPassword and LaunchSysPrefs scripts deleted successfully"

else

  echo "ADPassword and LaunchSysPrefs scripts removal FAILED"
  exit 1

fi

exit 0
