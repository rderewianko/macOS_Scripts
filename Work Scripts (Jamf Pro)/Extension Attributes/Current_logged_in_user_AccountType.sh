#!/bin/bash

########################################################################
#  Logged in user account type (Mobile or Local) - Extension Attribute #
################## Written by Phil Walker Oct 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Check if logged in user account is a mobile account
mobileAccount=$(dscl . -read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
  echo "<result>No logged in user</result>"
else
  if [[ "$mobileAccount" == "" ]]; then
    echo "<result>Local</result>"
  else
    echo "<result>Mobile</result>"
  fi
fi

exit 0
