#!/bin/sh

#####################################################################################################
############ Create hidden local admin account, setup Remote Management, enable SSH, ################
############ hide Other from login window and enable root user (10.6.x - 10.9.5 only) ###############
################################## Script Created by Phil Walker ####################################
#####################################################################################################

# replace all variable assignments with username and passwords of your choice

adminusername=adminusername
FullAdminUsername=fulladminusername
adminpwd=adminpassword
rootpwd=rootpassword

# RemoteManagement
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

# Create local admin account

echo "creating local admin account..."

dscl . -create /Users/$adminusername
dscl . -create /Users/$adminusername RealName "$FullAdminUsername"
dscl . -create /Users/$adminusername UniqueID 401
dscl . -create /Users/$adminusername PrimaryGroupID 20
dscl . -create /Users/$adminusername UserShell /bin/bash
dscl . -passwd /Users/$adminusername "$adminpwd"

# Set up a hidden home folder

dscl . -create /Users/$adminusername NFSHomeDirectory /var/$adminusername

# Grant admin

dseditgroup -o edit -a $adminusername -t user admin

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

# Hide Admin User from Login Window OS X 10.9.5 and below

echo "hiding admin account from login window..."

# Hide Admin from login window
defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $adminusername

# Enable Root User

echo "enabling root user..."

dsenableroot -u $adminusername -p $adminpwd -r $rootpwd

# Remove Other (root) from login window

defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE
exit 0
