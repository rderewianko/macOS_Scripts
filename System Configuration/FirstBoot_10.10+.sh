#!/bin/sh

#####################################################################################################
############ Create hidden local admin account, setup Remote Management, enable SSH, ################
####################### hide Other from login window and enable root user ###########################
################################## Script Created by Phil Walker ####################################
#####################################################################################################

#replace all variable assignments with username and passwords of your choice

adminusername=adminusername
FullAdminUsername=fulladminusername
adminpwd=adminpassword
rootpwd=rootpassword

# RemoteManagement
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

# Create a local admin user account

echo "creating local admin account..."

sysadminctl -addUser $adminusername -fullName $FullAdminUsername -UID 499 -password $adminpwd -home /var/admin -admin

# Setup Remote Management

echo "Remote Management being configured...."

$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -privs -all -users $adminusername,root
$ARD -configure -activate -restart -console

# Grant local admin account SSH access

echo "SSH access being configured...."

systemsetup -setremotelogin on
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a $adminusername -t user com.apple.access_ssh
launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# Hide Admin User account

dscl . create /Users/$adminusername IsHidden 1

# Hide root user (Other) from login window

echo "hiding Other from login window..."

defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE

#Enable Root User

echo "enabling root user..."

dsenableroot -u admin -p $adminpwd -r $rootpwd

# Set the time zone to London
systemsetup -settimezone "Europe/London"

exit 0
