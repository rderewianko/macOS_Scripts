#!/bin/bash

########################################################################
#   Remove Temp Admin Rights required for SecureToken (10.15+ only)    #
################### Written by Phil Walker Nov 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

#Loop through each account found, excludes root and any account with admin in the name - this stops casadmin, admin and any ADadmin accounts from being removed from the admin group
for user in $adminUsers
do
    if [[ "$user" != "root" && "$user" != *"admin"* ]]; then
        dseditgroup -o edit -d $user -t user admin
        if [ $? = 0 ]; then
          echo "Removed $user from admin group"
        fi
    else
        echo "Admin user $user left alone"
    fi
done

#Double check that the logged in user has been removed from the admin group
#re-populate variable
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
if [[ "$adminUsers" =~ "$loggedInUser" ]]; then
  echo "${loggedInUser} still a member of the admin group, removing admin rights..."
  dseditgroup -o edit -d $loggedInUser -t user admin
  #re-populate variable
  adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
    if [[ "$adminUsers" =~ "$loggedInUser" ]]; then
      echo "${loggedInUser} still a member of the admin group"
      echo "${loggedInUser}'s admin rights must be removed manually"
      exit 1
    fi
fi

exit 0
