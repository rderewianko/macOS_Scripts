#!/bin/sh

########################################################################
#  List logged in user's bluetooth devices (Paired, Configured, etc.)  #
################ Written by Suleyman Twana & Phil Walker ###############
########################################################################

#This script will only list the paired devices that contain the logged in users first name

########################################################################
#                            Variables                                 #
########################################################################

loggedInUser=$(stat -f %Su /dev/console)
mobileAccount=$(dscl . -read /Users/$loggedInUser OriginalNodeName 2>/dev/null)
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

BTDevicesAll=$(system_profiler SPBluetoothDataType > /tmp/BT.txt)
BTDevices1=$(cat /tmp/BT.txt | grep -i "$firstName" | grep -vi "wireless" | grep -vi "iPhone-Wirel" | sed 's/://g' | sed -e 's/^[ \t]*//' | tr -cd '\11\12\15\40-\176' | sort -u)
BTDevices2=$(cat /tmp/BT.txt | grep -i "magic" | sed 's/Services//g' | sed 's/://g' | sed -e 's/^[ \t]*//' | sort -u)
BTDevices3=$(cat /tmp/BT.txt | grep -i "Galaxy\|HUAWEI\|Samsung" | sed 's/://g' | sed -e 's/^[ \t]*//' | sort -u)

if [[ "$firstName" == "" ]] && [[ "$BTDevices2" == "" ]] && [[ "$BTDevices3" == "" ]]; then
  echo "<result></result>"
elif [[ "$firstName" == "" ]] && [[ "$BTDevices2" != "" || "$BTDevices3" != "" ]]; then
  echo "<result>"${BTDevices2}${BTDevices3}"</result>"
else
  if [[ "$BTDevices1" == "" ]] && [[ "$BTDevices2" == "" ]] && [[ "$BTDevices3" == "" ]]; then
    echo "<result></result>"
  else
    echo "<result>"${BTDevices1}${BTDevices2}${BTDevices3}"</result>"
    sleep 2
    rm /tmp/BT.txt
  fi
fi

exit 0
