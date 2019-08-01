#!/bin/bash

########################################################################
#                  Connected Bluetooth Devices EA                      #
############### written by Suleyman Twana and Phil Walker ##############
########################################################################

loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
mobileAccount=$(dscl . read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)

if [[ "$mobileAccount" == "" ]]; then
  userName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2}' | sed s/,//)
else
  userName=$(dscl . -read /Users/$loggedInUser | grep -i "LastName" | awk  '{print $2}')
fi

BTDevices1=$(system_profiler SPBluetoothDataType > /tmp/BT.txt)
BTDevices2=$(cat /tmp/BT.txt | grep -i "$userName" | grep -vi "wireless" | sed 's/://g' | sed -e '/^ *$/d')
  if [[ $loggedInUser == "root" ]]; then
    exit 0
  else
      if [[ $userName == "" ]]; then
        exit 0
      else
        if [[ $BTDevices2 == "" ]]; then
          echo "<result></result>"
        else
          echo "<result>"$BTDevices2"</result>"
          sleep 5
          rm /tmp/BT.txt
        fi
    fi
fi
exit 0
