#!/bin/bash

#This script removes the Bauer menu bar application and launch agent

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

########################################################################
#                            Functions                                 #
########################################################################

function launchAgentStatus()
{
#Get the status of the Bauer menu bar Launch Agent
launchAgent=$(su -l "$loggedInUser" -c "launchctl list | grep "hostname" | cut -f3")

if [[ "$launchAgent" == "com.hostname.menubar" ]]; then
  /bin/echo "Bauer menu bar Launch Agent running"
else
  /bin/echo "Bauer menu bar Launch Agent stopped and unloaded"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d /Library/Application\ Support/JAMF/bitbar/ ]]; then
        rm -rf /Library/Application\ Support/JAMF/bitbar/
        /bin/echo "BitBar application removed"
else
        /bin/echo "BitBar application not found in JAMF folder"
fi

if [[ -a /Library/LaunchAgents/com.hostname.menubar.plist ]]; then
        su -l "$loggedInUser" -c "launchctl stop /Library/LaunchAgents/com.hostname.menubar.plist"
        su -l "$loggedInUser" -c "launchctl unload /Library/LaunchAgents/com.hostname.menubar.plist"
        sleep 2
        rm -f /Library/LaunchAgents/com.hostname.menubar.plist
        launchAgentStatus
else
        /bin/echo "Bauer menu bar launch agent not found"
fi

#Kill the bitbar app now
killall BitBarDistro
/bin/echo "BitBar app killed"

exit 0
