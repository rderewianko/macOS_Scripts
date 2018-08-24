#!/bin/bash

#This script removes the Bauer menu bar application and lauchagents

if [[ -d /Library/Application\ Support/JAMF/bitbar/ ]]; then
        rm -rf /Library/Application\ Support/JAMF/bitbar/
        echo "Bitbar application removed"
else
        echo "bitbar not found in JAMF folder"
fi

if [[ -a /Library/LaunchAgents/com.hostname.menubar.plist ]]; then
        launchctl stop /Library/LaunchAgents/com.hostname.menubar.plist
        launchctl unload /Library/LaunchAgents/com.hostname.menubar.plist
        rm /Library/LaunchAgents/com.hostname.menubar.plist
        echo "menubar hostname launch agent stopped and removed"
else
        "menubar hostname launch agent not found"
fi

#Killthe bitbar app now
killall BitBarDistro
echo " BitBar app killed"

exit 0
