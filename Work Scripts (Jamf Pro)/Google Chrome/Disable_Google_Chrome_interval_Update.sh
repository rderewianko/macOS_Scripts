#!/bin/bash

########################################################################
#                  Disable Google Software Updater                     #
################## written by Phil Walker Mar 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Get the value of the update check
GoogleUpdateInterval=$(su -l "$LoggedInUser" -c "defaults read com.google.Keystone.Agent checkInterval")

########################################################################
#                         Script starts here                           #
########################################################################

#Check if the updater is set to 0
if [[ "$GoogleUpdateInterval" -eq "0" ]]; then
    echo "Google Updater already disabled, nothing to do"
else
  #Change the update plist to 0
  su -l "$LoggedInUser" -c "defaults write com.google.Keystone.Agent checkInterval 0"
  #Check changes have been applied
  GoogleUpdateInterval=$(su -l "$LoggedInUser" -c "defaults read com.google.Keystone.Agent checkInterval")
    if [[ "$GoogleUpdateInterval" -eq "0" ]]; then
      echo "Success Google Software Updater disabled"
      exit 0
    else
      echo "ERROR - Google Software Updater still enabled"
      exit 1
    fi
fi
