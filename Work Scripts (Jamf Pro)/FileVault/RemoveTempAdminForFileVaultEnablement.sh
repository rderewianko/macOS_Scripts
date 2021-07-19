#!/bin/bash

########################################################################
#   Remove Temp Admin Rights required for SecureToken (10.15+ only)    #
################### Written by Phil Walker Nov 2019 ####################
########################################################################
# Edit Apr 2021

########################################################################
#                            Variables                                 #
########################################################################
############ Variables for Jamf Pro Parameters - Start #################
# Management account username
mngmtAccount="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

########################################################################
#                         Script starts here                           #
########################################################################

echo "Checking for accounts created as admin users for FileVault enablement..."
# Loop through each account found and remove them from the admin group (excluding root, admin and the management account)
for user in $adminUsers; do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "$mngmtAccount" ]]; then
        dseditgroup -o edit -d "$user" -t user admin
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Removed $user from admin group"
        fi
    fi
done
exit 0