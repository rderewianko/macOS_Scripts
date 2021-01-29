#!/bin/zsh

########################################################################
#                           Configure ARD                              #
################### Written by Phil Walker Dec 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Check local admin is configured for ARD
ardConfigForAdmin=$(dscl . -list /Users naprivs | awk '{print $1}' | grep "admin")
# ARD Kickstart
ardKickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$ardConfigForAdmin" != "admin" ]]; then
    echo "Configuring ARD..."
    # Activate and enable for specified users only
    "$ardKickstart" -activate -configure -allowAccessFor -specifiedUsers
    # Enable for admin and root and give them all privs
    "$ardKickstart" -configure -access -on -privs -all -users admin,root
    # Enable the menubar icon so users can see if they are being controlled
    "$ardKickstart" -configure -clientopts -setmenuextra -menuextra yes
    # Restart the client to ensure that all config changes are in place
    "$ardKickstart" -restart -agent -console -menu
    # re-populate variable post changes
    ardConfigForAdmin=$(dscl . -list /Users naprivs | awk '{print $1}' | grep "admin")
    if [[ "$ardConfigForAdmin" == "admin" ]]; then
        echo "ARD configured successfully"
    else
        echo "Failed to configure ARD for admin!"
    fi
else
    echo "ARD is already configured, nothing to do"
fi
exit 0