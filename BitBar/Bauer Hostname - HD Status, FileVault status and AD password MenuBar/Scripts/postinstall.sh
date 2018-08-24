#!/bin/sh
## Load the launch agent now so the uploader works after pacakge install.

launchctl load /Library/LaunchAgents/com.hostname.menubar.plist
launchctl start /Library/LaunchAgents/com.hostname.menubar.plist

exit 0
