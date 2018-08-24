#!/bin/sh

#################################################
############ Configure ARD Agent ################
######## Script Created by Phil Walker ##########
#################################################

# RemoteManagement
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

#Admin username
adminusername=adminusername

# Setup Remote Management

$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -privs -all -users $adminusername,root
$ARD -configure -activate -restart -console

echo "ARDAgent now configured"

exit 0
