#!/bin/sh

#################################################
############ Configure SSH Access ###############
######## Script Created by Phil Walker ##########
#################################################

#replace variable assignment with username of your choice

adminusername=adminusername

systemsetup -setremotelogin on
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a $adminusername -t user com.apple.access_ssh
launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
launchctl load -w /System/Library/LaunchDaemons/ssh.plist

echo "SSH access now configured"
exit 0
