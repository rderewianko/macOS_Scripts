#!/bin/sh

#######################################################
############ Create admin user account 10.10+ #########
############# Script created by Phil Walker ###########
#######################################################

#replace all variable assignments with username and password of your choice

adminusername=adminusername
FullAdminUsername=fulladminusername
adminpwd=adminpassword

# Create a local admin user account

echo "creating local admin account..."

sysadminctl -addUser $adminusername -fullName $FullAdminUsername -UID 499 -password $adminpwd -home /var/admin -admin

echo "$FullAdminUsername account created"

exit 0
