#!/bin/bash

#######################################################################
################ Reapply user profile permissions #####################
############## Created by Phil Walker September 2017 ##################
#######################################################################

###################
#### Variables ####
###################

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

###################
#### Functions ####
###################

function getUser ()
{
getuser1=$(su - $LoggedInUser -c /usr/bin/osascript <<EndGetUser1
tell application "System Events"
    activate
    set the_results to (display dialog ("Enter the username (lowercase) you wish to reapply permissions for") with title ("Reapply Permissions") buttons {"Cancel", "Continue"} default button "Continue" default answer "")
    set BUTTON_Returned to button returned of the_results
    set wks to text returned of the_results
end tell
EndGetUser1
)
echo "Username is : $getuser1"
}

function reapplyOwnership() {
#Reapply ownership to current user's profile
chown -R "$getuser1":"BAUER-UK\Domain Users" /Users/"$getuser1"
if [ $? = 0 ]; then
  echo "Correct ownership set"
else
  echo "Setting ownership failed"
fi
}

function accessPermissions() {
#Find all directories and files within the current user's home directory and set the correct access permissions
chmod 755 /Users/$getuser1
find /Users/$getuser1 -type d -mindepth 1 -maxdepth 1 -not -name "*.*" -not -name "Library" -not -name "Applications" -not -name "Public" -not -name "jnlp-applet" -not -name "cupit" -not -name "Creative Cloud Files" -not -name "OneDrive - Bauer Group" -print0 | xargs -0 chmod 700
find /Users/$getuser1 -type d -mindepth 2 -print0 | xargs -0 chmod 755
if [ $? = 0 ]; then
  echo "Correct access permissions set for all directories"
else
  echo "Setting access permissions for all directories failed"
fi
find /Users/$getuser1 -type f -mindepth 2 -print0 | xargs -0 chmod 644
if [ $? = 0 ]; then
  echo "Correct access permissions set for all files"
else
  echo "Setting access permissions for all files failed"
fi
}

###############################################
#              script starts here             #
###############################################

getUser
if [[ $getuser1 == "" ]]; then
  exit 1
else
echo "Applying correct ownership and access permissions to $getuser1's profile..."
reapplyOwnership
accessPermissions
fi

exit 0
