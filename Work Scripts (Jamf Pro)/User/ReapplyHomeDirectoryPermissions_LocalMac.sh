#!/bin/bash

#######################################################################
################ Reapply user profile permissions #####################
############## Created by Phil Walker September 2017 ##################
#######################################################################

###################
#### Variables ####
###################

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
userRealName=`dscl . -read /Users/$LoggedInUser | grep -A1 "RealName:" | sed -n 2p | awk '{print $2, $1}' | sed 's/,$//'`

###################
#### Functions ####
###################

function reapplyOwnership() {
#Reapply ownership to current user's profile
chown -R "$LoggedInUser":"BAUER-UK\Domain Users" /Users/"$LoggedInUser"
if [ $? = 0 ]; then
  echo "Correct ownership set"
else
  echo "Setting ownership failed"
fi
}

function accessPermissions() {
#Find all directories and files within the current user's home directory and set the correct access permissions
chmod 755 /Users/$LoggedInUser
find /Users/$LoggedInUser -type d -mindepth 1 -maxdepth 1 -not -name "*.*" -not -name "Library" -not -name "Applications" -not -name "Public" -not -name "jnlp-applet" -not -name "cupit" -not -name "Creative Cloud Files" -not -name "OneDrive - Bauer Group" -print0 | xargs -0 chmod 700
find /Users/$LoggedInUser -type d -mindepth 2 -print0 | xargs -0 chmod 755
if [ $? = 0 ]; then
  echo "Correct access permissions set for all directories"
else
  echo "Setting access permissions for all directories failed"
fi
find /Users/$LoggedInUser -type f -mindepth 2 -print0 | xargs -0 chmod 644
if [ $? = 0 ]; then
  echo "Correct access permissions set for all files"
else
  echo "Setting access permissions for all files failed"
fi
}

###############################################
#              script starts here             #
###############################################

echo "Applying correct ownership and access permissions to $userRealName's profile..."
reapplyOwnership
accessPermissions

exit 0
