#!/bin/sh

###############################################
##### Open Application as Logged In User ######
####### Created by Phil Walker May 2017 #######
###############################################

# Amend variable assignment for Application as required

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

App="Softphone"

su -l $LoggedInUser -c "open -a $App"

exit 0
