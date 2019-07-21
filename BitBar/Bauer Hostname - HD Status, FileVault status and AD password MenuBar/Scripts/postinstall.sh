#!/bin/bash

#Remove redundant content based on model/OS version and NoMAD status
#Load the launch agent so that BitBar works after the package install

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#ADPassword and launchSysPrefstoUserPane script locations
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

#Mac model and marketing name
macModel=$(sysctl -n hw.model)
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)

#OS Version Full and Short
OSFull=$(sw_vers -productVersion)
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')

#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

########################################################################
#                            Functions                                 #
########################################################################

function checkScriptRemoval()
{
#Remove the ADPassword and LaunchSysPrefs scripts

#re-populate ADPassword and launchSysPrefstoUserPane script variables
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"
LaunchSysPrefs="/usr/local/launchSysPrefstoUserPane.sh"

if [[ ! -a "$BitBarAD" ]] && [[ ! -a $LaunchSysPrefs ]]; then

  /bin/echo "ADPassword and LaunchSysPrefs scripts deleted successfully"

else

  /bin/echo "ADPassword and LaunchSysPrefs scripts removal FAILED. post install clean up tasks have not completed successfully"
  exit 1

fi
}

function launchAgentStatus()
{
#Get the status of the Bauer menu bar Launch Agent
launchAgent=$(su -l "$loggedInUser" -c "launchctl list | grep "hostname" | cut -f3")

if [[ "$launchAgent" == "com.hostname.menubar" ]]; then
  /bin/echo "Bauer menu bar Launch Agent running"
else
  /bin/echo "Bauer menu bar Launch Agent currently stopped/unloaded"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Remove the ADPassword and LaunchSysPrefs scripts if NoLoAD is installed or OS is 10.14+

if [[ "$macModel" =~ "MacBook" ]] && [[ "$OSShort" == "12" ]]; then
  /bin/echo "${macModelFull} running ${OSFull}"
  if [[ -d "$noLoADBundle" ]]; then
    /bin/echo "NoMAD Login AD installed, ADPassword and LaunchSysPrefs scripts not required"
    #Remove ADPassword script
      rm -f "$BitBarAD"
    #Remove LaunchSysPrefs script
      rm -f "$LaunchSysPrefs"
      checkScriptRemoval
  fi
elif [[ "$OSShort" -ge "14" ]]; then
  /bin/echo "OS version is $OSFull, ADPassword and LaunchSysPrefs scripts not required"
  #Remove ADPassword script
    rm -f "$BitBarAD"
  #Remove LaunchSysPrefs script
    rm -f "$LaunchSysPrefs"
    checkScriptRemoval
fi

su -l "$loggedInUser" -c "launchctl load /Library/LaunchAgents/com.hostname.menubar.plist"
su -l "$loggedInUser" -c "launchctl start /Library/LaunchAgents/com.hostname.menubar.plist"

sleep 2
launchAgentStatus

exit 0
