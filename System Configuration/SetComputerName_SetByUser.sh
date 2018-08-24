#!/bin/sh

#######################################################
################# Set Computer Name ###################
############# Script created by Phil Walker ###########
#######################################################

echo ""
echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "What would you like it to be?"
  read COMPUTER_NAME
  scutil --set ComputerName $COMPUTER_NAME
  scutil --set HostName $COMPUTER_NAME
  scutil --set LocalHostName $COMPUTER_NAME
  defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
fi
exit 0
