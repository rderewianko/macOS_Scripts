#!/bin/bash

########################################################################
#                         MobileSync Status                            #
################## Written by Phil Walker July 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Get the current user's home directory
userHomeDirectory=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Check for a MobileSync backup directory
#mobileSync=$(ls "${userHomeDirectory}/Library/Application Support/" | grep "MobileSync")
mobileSync=$(ls "${userHomeDirectory}/Library/Application Support/MobileSync/Backup" | wc -l)
# OS Version Short
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

#if [[ "$mobileSync" == "MobileSync" ]]; then
#  /bin/echo "<result>Backup Found</result>"
#else
#  /bin/echo "<result>No Backup</result>"
#fi

if [[ "$mobileSync" -ge "1" ]]; then
  /bin/echo "<result>Backup Found</result>"
else
  /bin/echo "<result>No Backup</result>"
fi

exit 0
