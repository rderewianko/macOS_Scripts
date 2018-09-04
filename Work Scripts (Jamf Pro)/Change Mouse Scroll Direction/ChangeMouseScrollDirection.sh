#!/bin/bash

###############################################
# This script sets the mouse scroll direction #
###############################################

# IF a change is made it does not apply until the next logon session

#########################
#       Variables       #
#########################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#########################
#       Functions       #
#########################

function preCheck() {
#Read the value set for com.apple.swipescrolldirection.
local PREF=$(/usr/libexec/PlistBuddy -c "print com.apple.swipescrolldirection" /Users/$LoggedInUser/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
#Confirm that the value has been set successfully
if [[ $PREF == "false" ]]; then
  echo "Natural Mouse scroll direction already turned off, nothing to do"
  exit 0
else
  echo "Mouse scroll direction currently set to Natural, turning setting off..."
fi

}

function postCheck() {
#Check that the value has been set for com.apple.swipescrolldirection successfully
#Read the value set for com.apple.swipescrolldirection.
local PLIST=$(/usr/libexec/PlistBuddy -c "print com.apple.swipescrolldirection" /Users/$LoggedInUser/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
#Confirm that the value has been set successfully
if [[ $PLIST == "false" ]]; then
  echo "Natural Mouse scroll direction successfully turned off"
else
  echo "Setting Mouse scroll direction failed"
  exit 1
fi

}

##########################
#   script starts here   #
##########################

#Check to see if a change needs to be made
preCheck

#Set Natural scroll direction to false
su $LoggedInUser -c "defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool False"

#Check the change has been implemented successfully
postCheck

#Kill System Preferences so that the change displays correctly
killall -HUP System\ Preferences 2>/dev/null

exit 0
