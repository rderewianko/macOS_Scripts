#!/bin/bash
## Load and start the launch agent

launchctl load /Library/LaunchAgents/com.hostname.menubar.plist
launchctl start /Library/LaunchAgents/com.hostname.menubar.plist

exit 0
