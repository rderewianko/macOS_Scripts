#!/bin/sh

#######################################################
######### Create admin user account (Pre 10.10.x) #####
############# Script created by Phil Walker ###########
#######################################################

#replace all variable assignments with username and passwords of your choice

adminusername=adminusername
FullAdminUsername=fulladminusername
adminpwd=adminpassword

# Create a local admin user account

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

#Hide Admin User from the Login Window

echo "hiding admin account from the login window..."

defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $adminusername

echo "$FullAdminUsername account created"

exit 0
