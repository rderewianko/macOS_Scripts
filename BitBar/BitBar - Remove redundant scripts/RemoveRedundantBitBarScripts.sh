#!/bin/sh

########################################################################
#                Remove Redundant BitBar scripts                       #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

# Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

########################################################################
#                            Functions                                 #
########################################################################

function noMADLoginAD ()
{

if [[ ! -d "$noLoADBundle" ]]; then
  echo "NoMAD Login AD not installed, nothing to do"
  exit 0
else
  echo "NoMAD Login AD installed"
fi

}

function checkScripts ()
{

if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then
  echo "ADPassword.1d.sh and launchSysPrefstoUserPane.sh not found, nothing to do"
  echo "Exiting script......."
  exit 0
else
  echo "ADPassword.1d.sh and launchSysPrefstoUserPane.sh found, will both be removed"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

# Check that NoMAD Login AD is installed
noMADLoginAD

# Check ADPassword and LaunchSysPrefs scripts are present
checkScripts

echo "Removing ADPassword.1d.sh and launchSysPrefstoUserPane.sh..."

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
