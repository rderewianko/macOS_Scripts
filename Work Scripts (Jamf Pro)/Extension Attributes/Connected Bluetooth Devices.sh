#!/bin/bash

########################################################################
#  List logged in user's bluetooth devices (Paired, Configured, etc.)  #
################ Written by Suleyman Twana & Phil Walker ###############
########################################################################

#This script will only list the paired devices that contain the logged in users first name

########################################################################
#                            Variables                                 #
########################################################################

loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
mobileAccount=$(dscl . read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)
loggedInUserUID=$(dscl . -read /Users/$loggedInUser UniqueID | awk '{print $2}')

########################################################################
#                            Functions                                 #
########################################################################

function getFirstName()
{
#Get first name of the logged in user.
if [[ "$mobileAccount" == "" ]]; then
  if [[ "$loggedInUserUID" -lt "1000" ]]; then
      firstName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1}' | sed s/,//)
  else
      firstName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2}' | sed s/,//)
  fi
else
    firstName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2}' | sed s/,//)
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

getFirstName

BTDevices1=$(system_profiler SPBluetoothDataType > /tmp/BT.txt)
BTDevices2=$(cat /tmp/BT.txt | grep -i "$firstName" | grep -vi "wireless" | grep -vi "iPhone-Wirel" | sed 's/://g' | sed -e '/^ *$/d')
  if [[ "$loggedInUser" == "root" ]]; then
    exit 0
  else
      if [[ "$firstName" == "" ]]; then
        exit 0
      else
        if [[ "$BTDevices2" == "" ]]; then
          echo "<result></result>"
        else
          echo "<result>"$BTDevices2"</result>"
          sleep 2
          rm /tmp/BT.txt
        fi
    fi
fi

exit 0
