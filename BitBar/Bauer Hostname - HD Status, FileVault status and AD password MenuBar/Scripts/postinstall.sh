#!/bin/sh
## Load the launch agent now so that BitBar works after the package install.

#Get the OS version
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')
OSFull=$(sw_vers -productVersion)

#ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

#Remove the ADPassword and LaunchSysPrefs scripts if 10.14 or above

if [[ "$OSShort" -ge "14" ]]; then

  echo "OS version is $OSFull, ADPassword and LaunchSysPrefs scripts not required"

#Remove ADPassword script
  rm -f "$BitBarAD"
#Remove LaunchSysPrefs script
  rm -f "$LaunchSysPrefs"

  if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then

    echo "ADPassword and LaunchSysPrefs scripts deleted successfully"

  else

    echo "ADPassword and LaunchSysPrefs scripts removal FAILED. post install clean up tasks have not completed successfully"
    exit 1

  fi
fi

launchctl load /Library/LaunchAgents/com.hostname.menubar.plist
launchctl start /Library/LaunchAgents/com.hostname.menubar.plist

exit 0
