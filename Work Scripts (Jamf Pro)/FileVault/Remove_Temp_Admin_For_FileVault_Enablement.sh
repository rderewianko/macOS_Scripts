#!/bin/bash

########################################################################
#   Remove Temp Admin Rights required for SecureToken (10.15+ only)    #
################### Written by Phil Walker Nov 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

########################################################################
#                         Script starts here                           #
########################################################################

echo "Checking for accounts created as admin users for FileVault enablement..."
# Loop through each account found and remove them from the admin group (excluding root, admin and casadmin)
for user in $adminUsers; do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "casadmin" ]]; then
        dseditgroup -o edit -d "$user" -t user admin
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Removed $user from admin group"
        fi
    fi
done

# Double check that the logged in user has been removed from the admin group
# re-populate admin group variable
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
if [[ "$adminUsers" =~ ${loggedInUser} ]]; then
    echo "${loggedInUser} still a member of the admin group, removing admin rights..."
    dseditgroup -o edit -d "$loggedInUser" -t user admin
    # re-populate variable
    adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
    if [[ "$adminUsers" =~ ${loggedInUser} ]]; then
        echo "${loggedInUser} still a member of the admin group"
        echo "${loggedInUser}'s admin rights must be removed manually"
        exit 1
    fi
fi
exit 0