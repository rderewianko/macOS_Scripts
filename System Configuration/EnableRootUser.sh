#!/bin/sh

################################################################################################################
############ Enable root user and hide Other (root) from the login window (10.6.x - 10.9.5 only) ###############
################################ Script Created by Phil Walker #################################################
################################################################################################################

# replace all variable assignments with username and passwords of your choice

adminusername=adminusername
adminpwd=adminpassword
rootpwd=rootpassword

# Enable Root User

echo "enabling root user..."

dsenableroot -u $adminusername -p $adminpwd -r $rootpwd

# Remove Other (root) from login window

defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE

echo "Other (root) now hidden from the login window"
exit 0
