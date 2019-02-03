#!/bin/sh

########################################################################
#                Remove Redundant BitBar scripts                       #
#                   (Mojave and above only)                            #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the OS version
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')
OSFull=$(sw_vers -productVersion)

#ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

########################################################################
#                            Functions                                 #
########################################################################

#Double check if the policy should be run
function checkOS ()
{

if [[ "$OSShort" -lt "14" ]]; then
  echo "OS Version is $OSFull, nothing will be removed"
  echo "Exiting script......."
  exit 0
else
  echo "OS Version is $OSFull, checking for ADPassword and LaunchSysPrefs scripts..."
fi

}

function checkScripts ()
{

if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then
  echo "ADPassword.1d.sh and launchSysPrefstoUserPane.sh not found, nothing to do"
  echo "Exiting script......."
  exit 0
else
  echo "ADPassword.1d.sh and launchSysPrefstoUserPane.sh found, both will be removed"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

#Check OS is 10.14 or above
checkOS
#Check ADPassword and LaunchSysPrefs scripts are present
checkScripts

echo "Removing ADPassword.1d.sh and launchSysPrefstoUserPane.sh..."

#Remove ADPassword script
rm -f "$BitBarAD"
#Remove LaunchSysPrefs script
rm -f "$LaunchSysPrefs"

#Check removal was successful
echo "Checking removal was successful"
if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then

  echo "ADPassword and LaunchSysPrefs scripts deleted successfully"

else

  echo "ADPassword and LaunchSysPrefs scripts removal FAILED"
  exit 1

fi

exit 0
