#!/bin/bash
## postinstall

## Load the launch daemon

launchctl load /Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist
launchctl start /Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist
echo "NoMAD Login AD auth check launch daemon loaded and started"

exit 0
