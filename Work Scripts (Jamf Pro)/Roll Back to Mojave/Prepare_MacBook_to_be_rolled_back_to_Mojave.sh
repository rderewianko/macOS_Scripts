#!/bin/bash

########################################################################
#          Prepare a MacBook to be rolled back to Mojave               #
################### Written by Phil Walker Feb 2020 ####################
########################################################################

#Required when wanting to roll back a MacBook (T2) that has shipped with Catalina

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users GUID
loggedInUserGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')
# Get the logged in user's SecureToken status
loggedInUserSecureToken=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
# Get the logged in user's FileVault status
loggedInUserFVStatus=$(/usr/bin/fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUserSecureToken" =~ "ENABLED" ]] && [[ "$loggedInUserGUID" == "$loggedInUserFVStatus" ]]; then
  echo "$loggedInUser has a SecureToken and is a FileVault enabled user, continuing..."
    #Promote the logged in user to an admin
    dseditgroup -o edit -a "$loggedInUser" -t user admin
    #Get a list of users who are in the admin group
    adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
    #Check if the logged in user is in the admin group
    if [[ "$adminUsers" =~ "$loggedInUser" ]]; then
      echo "$loggedInUser is now an admin"
    else
      echo "Failed to grant temp admin rights, exiting!"
      exit 1
    fi
    #Update preBoot to enable the logged in user access to change the startup security settings (Secure Boot)
    diskutil quiet apfs updatepreBoot /
    echo "preBoot updated"
    #Set next boot to Recovery Partition
    nvram internet-recovery-mode=RecoveryModeDisk
    echo "Next boot set to Recovery Partition"
else
  echo "Failed to grant temp admin so process cannot be completed!"
  exit 1
fi

exit 0
