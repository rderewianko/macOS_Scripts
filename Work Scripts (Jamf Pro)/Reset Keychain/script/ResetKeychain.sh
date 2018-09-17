#!/bin/bash

######################################################################
#    Reset Local Items and Login Keychain for the logged in user     #
############### Written by Phil Walker May 2018 ######################
######################################################################

#########################
#       Variables       #
#########################

#Get the logged in user
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
echo "Current user is $LoggedInUser"

#Get the current user's home directory
UserHomeDirectory=$(/usr/bin/dscl . -read /Users/"${LoggedInUser}" NFSHomeDirectory | awk '{print $2}')

#Get the current user's default (login) keychain
CurrentLoginKeychain=$(su "${LoggedInUser}" -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}')

#Check Pre-Sierra Login Keychain
loginKeychain="${UserHomeDirectory}"/Library/Keychains/login.keychain 2>/dev/null

#Hardware UUID
HardwareUUID=$(system_profiler SPHardwareDataType | grep 'Hardware UUID' | awk '{print $3}')

#Local Items Keychain
LocalKeychain=$(ls "${UserHomeDirectory}"/Library/Keychains/ | egrep '([A-Z0-9]{8})((-)([A-Z0-9]{4})){3}(-)([A-Z0-9]{12})' | head -n 1)

#Keychain Backup Directory
KeychainBackup="${UserHomeDirectory}/Library/Keychains/KeychainBackup"

#########################
#      Functions        #
#########################

function createBackupDirectory() {
#Create a directory to store the previous Local and Login Keychain so that it can be restored
if [[ ! -d "$KeychainBackup" ]]; then
  mkdir "$KeychainBackup"
  chown $LoggedInUser:"BAUER-UK\Domain Users" "$KeychainBackup"
  chmod 755 "$KeychainBackup"
else
    rm -Rf "$KeychainBackup"/*
fi
}

function loginKeychain() {
#Check the login default keychain and move it to the backup directory if required
if [[ -z "$CurrentLoginKeychain" ]]; then
  echo "Default Login keychain not found, nothing to delete or backup"
else
  echo "Login Keychain found and now being moved to the backup location..."
  mv "${UserHomeDirectory}/Library/Keychains/$CurrentLoginKeychain" "$KeychainBackup"
  mv "$loginKeychain" "$KeychainBackup" 2>/dev/null
fi

}

function checkLocalKeychain() {
#Check the Hardware UUID matches the Local Keychain and move it to the backup directory if required
if [[ "$LocalKeychain" == "$HardwareUUID" ]]; then
  echo "Local Keychain found and matches the Hardware UUID, backing up Local Items Keychain..."
  mv "${UserHomeDirectory}/Library/Keychains/$LocalKeychain" "$KeychainBackup"
elif [[ "$LocalKeychain" != "$HardwareUUID" ]]; then
  echo "Local Keychain found but does not match Hardware UUID so must have been restored, backing up Local Items Keychain..."
  mv "${UserHomeDirectory}/Library/Keychains/$LocalKeychain" "$KeychainBackup"
else
  echo "Local Keychain not found, nothing to backup or delete"
fi
}

function timeMachineCheck ()
{
#Check if the Backup partition is present and if so has TM completed a backup today
BackupPartition=`diskutil list | grep "Backup" | awk '{ print $3 }' | head -n 1`
DATE=`date | awk '{print $2,$3,$6}'`
BackupDate=`ls -l /Volumes/Backup/Backups.backupdb/* 2>/dev/null | grep "Latest" | awk '{print $6,$7,$11}' | sed 's/-.*//'`

if [[ "$BackupPartition" != "Backup" ]]; then
    echo "Backup partition could not be found.."
    echo "A KeychainBackup directory will be created..."
    createBackupDirectory
    loginKeychain
    checkLocalKeychain
    #Set correct permissions for backup Directory
    chown -R $LoggedInUser:"BAUER-UK\Domain Users" "$KeychainBackup"

elif [[ "$BackupPartition" == "Backup" ]] && [[ "$DATE" != "$BackupDate" ]]; then
    echo "Backup partition found but TM backup is not recent (Latest Backup:$BackupDate), KeychainBackup directory will be created..."
    createBackupDirectory
    loginKeychain
    checkLocalKeychain
    #Set correct permissions for backup Directory
    chown -R $LoggedInUser:"BAUER-UK\Domain Users" "$KeychainBackup"

else
  	echo "TM backup is recent (Latest Backup:$BackupDate), keychain now being deleted but can be restored from a Time Machine backup if required at a later date"
    rm -f ${UserHomeDirectory}/Library/Keychains/"$CurrentLoginKeychain" 2>/dev/null
    rm -f "$loginKeychain" 2>/dev/null
    rm -Rf ${UserHomeDirectory}/Library/Keychains/"$LocalKeychain" 2>/dev/null
    rm -Rf ${UserHomeDirectory}/Library/Keychains/"$HardwareUUID" 2>/dev/null
fi
}

#JamfHelper message advising that running this will delete all saved passwords
function jamfHelper_ResetKeychain ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "Reset Keychain" -description "Please save all of your work, once saved select the Reset button

Your Keychain will then be reset and your Mac will reboot

❗️All passwords currently stored in your Keychain will need to be entered again after the reset has completed" -button1 "Reset" -defaultButton 1

}


#JamfHelper message to confirm the keychain has been reset and the Mac is about to restart
function jamfHelper_KeychainReset ()
{
su - $LoggedInUser <<'jamfHelper1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "Reset Keychain" -description "Your Keychain has now been reset

Your Mac will now reboot to complete the process" &
jamfHelper1
}

#JamfHelper message to advise the customer the reset has failed
function jamfHelperKeychainResetFailed ()
{
su - $LoggedInUser <<'jamfHelper_keychainresetfailed'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title 'Message from Bauer IT' -heading 'Keychain Reset Failed' -description 'It looks like something went wrong when trying to reset your keychain.

Please contact the IT Service Desk

0345 058 4444

' -button1 "Ok" -defaultButton 1
jamfHelper_keychainresetfailed
}

function confirmKeychainDeletion() {
#repopulate login keychain variable (Only the login keychain is checked post deletion as the local items keychain is sometimes recreated too quickly)
CurrentLoginKeychain=$(su "${LoggedInUser}" -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}')

if [[ -z "$CurrentLoginKeychain" ]]; then
    echo "Keychain deleted or moved successfully. A reboot is required to complete the process"
else
  echo "Keychain reset FAILED"
  jamfHelperKeychainResetFailed
  exit 1
fi
}

##########################
#   script starts here   #
##########################

echo "Default Login Keychain: $CurrentLoginKeychain"
echo "Hardware UUID: $HardwareUUID"
echo "Local Items Keychain: $LocalKeychain"

jamfHelper_ResetKeychain

#Quit all open Apps
echo "Killing all Microsoft Apps to avoid MS Error Reporting launching"
ps -ef | grep Microsoft | grep -v grep | awk '{print $2}' | xargs kill -9
echo "Killing all other open applications for $LoggedInUser"
killall -u $LoggedInUser

echo "Checking for a recent Time Machine backup..."
timeMachineCheck

echo "Checking Keychain has been successfully reset"
confirmKeychainDeletion

jamfHelper_KeychainReset

sleep 5

killall jamfHelper

#include restart in policy for script results to be written to JSS
#or force a restart (results will not be written to JSS)
#shutdown -r now

exit 0
