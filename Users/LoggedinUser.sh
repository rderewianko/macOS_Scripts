#!/bin/sh

#######################################################
################# Current Logged in User ##############
############# Script created by Phil Walker ###########
#######################################################

#Old method to find the current logged in user
#LoggedInUser=$(stat -f "%Su" /dev/console)
#or
#LoggedInUser=$(ls -l /dev/console | awk '{ print $3 }')

# Apple recommended method to find the current logged in user

LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
echo "Current user is $LoggedInUser"
exit 0
