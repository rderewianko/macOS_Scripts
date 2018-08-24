#!/bin/sh

#######################################################
######## Set Computer Name (No user interaction) ######
############# Script created by Phil Walker ###########
#######################################################

# replace variable assignment with the computer name required

COMPUTER_NAME=computername

  scutil --set ComputerName $COMPUTER_NAME
  scutil --set HostName $COMPUTER_NAME
  scutil --set LocalHostName $COMPUTER_NAME
  defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
exit 0
