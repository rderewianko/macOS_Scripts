#!/bin/bash

########################################################################
#    Reset Local Items and Login Keychain for the logged in user       #
############### Written by Phil Walker May 2018 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

## Edited Jan 2019 to remove Time Machine checks and some commands as the user instead of root
## Edited further in Jan 2019 to add further checks for old login and local keychains. These are also backed up.
## Removed Hardware UUID removed as this check isnt really required.
## Latest edit due to several users having such messy keychains that they had multiple locked login
## and local keychains, so clearing only the current login and local keychains wasn't sufficient

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get the current user's home directory
UserHomeDirectory=$(/usr/bin/dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk '{print $2}')
#Get the current user's default (login) keychain
CurrentLoginKeychain=$(su -l "$LoggedInUser" -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}')
#Local Items Keychain
LocalKeychain=$(ls "${UserHomeDirectory}"/Library/Keychains/ | egrep '([A-Z0-9]{8})((-)([A-Z0-9]{4})){3}(-)([A-Z0-9]{12})' | head -n 1)
#Keychain Backup Directory
KeychainBackup="${UserHomeDirectory}/Library/Keychains/KeychainBackup"

########################################################################
#                            Functions                                 #
########################################################################

function createBackupDirectory ()
{
#Create a directory to store the previous Local and Login Keychain so that it can be restored
if [[ ! -d "$KeychainBackup" ]]; then
  echo "Creating directory KeychainBackup"
  su -l "$LoggedInUser" -c "mkdir "$KeychainBackup""
else
  echo "Removing previously backed up keychains from the KeychainBackup directory"
  rm -Rf "$KeychainBackup"/*
fi
}

function backupLoginKeychains ()
{
#Check for all Login keychains
echo "Checking for Login Keychains..."
for login in $(ls "${UserHomeDirectory}"/Library/Keychains/*.keychain* | grep -v "metadata")
  do
    echo "Login Keychain: $login"
    su -l "$LoggedInUser" -c "mv "$login" "$KeychainBackup""
  done

}

function backupLocalKeychain ()
{
#Check for all Local keychains
echo "Checking for Local Keychains..."
for local in $(ls "${UserHomeDirectory}"/Library/Keychains/ | egrep '([A-Z0-9]{8})((-)([A-Z0-9]{4})){3}(-)([A-Z0-9]{12})')
  do
    echo "Local Keychain: $local"
    su -l "$LoggedInUser" -c "mv ""${UserHomeDirectory}"/Library/Keychains/"$local"" "$KeychainBackup""
  done

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
su - "$LoggedInUser" <<'jamfHelper1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "Reset Keychain" -description "Your Keychain has now been reset

Your Mac will now reboot to complete the process" &
jamfHelper1
}

#JamfHelper message to advise the customer the reset has failed
function jamfHelperKeychainResetFailed ()
{
su - "$LoggedInUser" <<'jamfHelper_keychainresetfailed'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title 'Message from Bauer IT' -heading 'Keychain Reset Failed' -description 'It looks like something went wrong when trying to reset your keychain.

Please contact the IT Service Desk

0345 058 4444

' -button1 "Ok" -defaultButton 1
jamfHelper_keychainresetfailed
}

function confirmKeychainDeletion ()
{
#Check for existence of any login keychains (Only the login keychain is checked post deletion as the local items keychain is sometimes recreated too quickly)
AllLoginKeychains=$(ls "${UserHomeDirectory}"/Library/Keychains/ | grep ".keychain" | grep -v "metadata" | wc -l)

if [[ "$AllLoginKeychains" -eq "0" ]]; then
    echo "Keychain reset successfully. A reboot is required to complete the process"
else
  echo "Keychain reset FAILED"
  jamfHelperKeychainResetFailed
  exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

echo
echo "-------------INFO-------------"
echo "Current user is $LoggedInUser"
echo "Default Login Keychain: $CurrentLoginKeychain"
echo "Local Items Keychain: $LocalKeychain"

jamfHelper_ResetKeychain

echo "-------------PRE-RESET TASKS-------------"
#Quit all open Apps
echo "Killing all Microsoft Apps to avoid MS Error Reporting launching"
ps -ef | grep Microsoft | grep -v grep | awk '{print $2}' | xargs kill -9
echo "Killing all other open applications for $LoggedInUser"
killall -u "$LoggedInUser"

sleep 3 #avoids prompt to reset local keychain

#Reset the logged in users local and login keychain
createBackupDirectory
echo "-------------RESET KEYCHAIN-------------"
backupLoginKeychains
backupLocalKeychain

echo "-------------POST-RESET CHECK-------------"
confirmKeychainDeletion

jamfHelper_KeychainReset

sleep 5

killall jamfHelper

#include restart in policy for script results to be written to JSS
#or force a restart (results will not be written to JSS)
#shutdown -r now

exit 0
