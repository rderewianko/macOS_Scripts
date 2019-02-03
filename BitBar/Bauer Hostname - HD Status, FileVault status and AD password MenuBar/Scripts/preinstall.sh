#!/bin/bash

#This script removes the Bauer menu bar application and launch agents

if [[ -d /Library/Application\ Support/JAMF/bitbar/ ]]; then
        rm -rf /Library/Application\ Support/JAMF/bitbar/
        echo "BitBar application removed"
else
        echo "BitBar not found in JAMF folder"
fi

if [[ -a /Library/LaunchAgents/com.hostname.menubar.plist ]]; then
        launchctl stop /Library/LaunchAgents/com.hostname.menubar.plist
        launchctl unload /Library/LaunchAgents/com.hostname.menubar.plist
        rm /Library/LaunchAgents/com.hostname.menubar.plist
        echo "menubar hostname launch agent stopped and removed"
else
        echo "menubar hostname launch agent not found"
fi

#Kill the bitbar app now
killall BitBarDistro
echo " BitBar app killed"

exit 0
