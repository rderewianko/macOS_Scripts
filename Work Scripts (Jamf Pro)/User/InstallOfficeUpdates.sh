#!/bin/bash

#######################################################################
#                 Install all available Office updates                #
######################### written by Phil Walker ######################
#######################################################################

#MAU Location
MAU_Loc="/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate"
#Get the Logged in User
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Check for updates
MAU_List=$(su -l $LoggedInUser -c "$MAU_Loc --list" | sed -n 2p)

if [[ $MAU_List == "No updates available" ]]; then
  echo "No Updates available, exiting..."
  exit 0
else
  echo "Installing all available Office updates"
  su -l $LoggedInUser -c "$MAU_Loc --install"
fi

echo "All available Office updates installing...."

exit 0
