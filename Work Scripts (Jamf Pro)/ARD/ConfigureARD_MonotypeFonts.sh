#!/bin/zsh

########################################################################
#              Configure ARD for Monotype Fonts Testing                #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# ARD Kickstart
ardKickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

########################################################################
#                         Script starts here                           #
########################################################################

echo "Configuring ARD..."
# Activate and enable for specified users only
"$ardKickstart" -activate -configure -allowAccessFor -specifiedUsers &>/dev/null
# Enable for admin and root and give them all privs
"$ardKickstart" -configure -access -on -privs -all -users admin,root,monotype &>/dev/null
# Enable the menubar icon so users can see if they are being controlled
"$ardKickstart" -configure -clientopts -setmenuextra -menuextra yes &>/dev/null
# Restart the client to ensure that all config changes are in place
"$ardKickstart" -restart -agent -console -menu &>/dev/null
# Check changes
ardConfigForAdmin=$(dscl . -list /Users naprivs | awk '{print $1}' | grep "monotype")
if [[ "$ardConfigForAdmin" == "monotype" ]]; then
    echo "ARD configured successfully"
else
    echo "Failed to configure ARD for monotype!"
fi
exit 0