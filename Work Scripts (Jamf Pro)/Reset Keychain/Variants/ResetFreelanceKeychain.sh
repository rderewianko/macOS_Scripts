#!/bin/bash

######################################################################
#### Reset Local Items and Login Keychain for freelance accounts #####
############### Written by Phil Walker June 2018 #####################
######################################################################

#########################
####### Variables #######
#########################

#Get the logged in user
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
echo "Current user is $LoggedInUser"

#Get the current user's home directory
UserHomeDirectory=$(/usr/bin/dscl . -read Users/$LoggedInUser NFSHomeDirectory | awk '{print $2}')

#Get the current user's default (login) keychain
LoginKeychain=$(ls $UserHomeDirectory/Library/Keychains/login.*)

#Hardware UUID
HardwareUUID=$(system_profiler SPHardwareDataType | grep 'Hardware UUID' | awk '{print $3}')

#Local Items Keychain
LocalKeychain=$(ls $UserHomeDirectory/Library/Keychains/ | egrep '([A-Z0-9]{8})((-)([A-Z0-9]{4})){3}(-)([A-Z0-9]{12})' | head -n 1)


#########################
###### Functions ########
#########################


function deleteLoginKeychain() {
#Check the login default keychain and move it to the backup directory if required
if [[ $LoginKeychain == "" ]]; then
  echo "Default Login keychain not found"
else
  echo "Login Keychain found and now being deleted..."
  rm -f "$UserHomeDirectory/Library/Keychains/"login.*"" 2>/dev/null
fi

}

function deleteLocalKeychain() {
#Check the Hardware UUID matches the Local Keychain and move it to the backup directory if required
if [[ $LocalKeychain == $HardwareUUID ]]; then
  rm -Rf "$UserHomeDirectory/Library/Keychains/$LocalKeychain"
  echo "Local Keychain found and matches the Hardware UUID, deleting Local Items Keychain..."
elif [[ $LocalKeychain != $HardwareUUID ]]; then
  rm -Rf "$UserHomeDirectory/Library/Keychains/$LocalKeychain"
  echo "Local Keychain found but does not match Hardware UUID so must have been restored, deleting Local Items Keychain..."
  else
  echo "Local Keychain not found so nothing to delete"
fi
}


function confirmKeychainDeletion() {
#Re-populate login keychain variable
LoginKeychain=$(ls $UserHomeDirectory/Library/Keychains/login.* 2>/dev/null)

#Re-populate Local Items Keychain variable
LocalKeychain=$(ls $UserHomeDirectory/Library/Keychains/ | egrep '([A-Z0-9]{8})((-)([A-Z0-9]{4})){3}(-)([A-Z0-9]{12})' | head -n 1 2>/dev/null)

if [[ -z $LoginKeychain ]] && [[ ! -d $LocalKeychain ]]; then
    echo "Login & Local Items Keychains deleted or moved successfully, this Mac will now reboot to complete the process"
else
  echo "Keychain deletion FAILED"
  exit 1
fi
}

#JamfHelper message advising that running this will delete all saved passwords
function jamfHelper_ResetKeychain ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "Freelance Account Keychain Reset" -description "Please save all of your work, once saved select the reset button to close all currently open apps

Your Keychain will then be reset and the Mac will reboot" -button1 "Reset" -button2 "Cancel" -defaultButton 1 -cancelButton 2

}

#JamfHelper message to advise that they have cancelled the request
function jamfHelper_Cancelled ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarDeleteIcon.icns" -title "Message from Bauer IT" -heading "Freelance Account Keychain Reset" -description "Request cancelled

Nothing has been deleted" -button1 "Ok" -defaultButton 1

}

#JamfHelper message to confirm the cache has been deleted
function jamfHelper_KeychainReset ()
{
su - $LoggedInUser <<'jamfHelper1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Keychain\ Access.app/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "Freelance Account Keychain Reset" -description "Your Keychain has now been reset

Your Mac will now reboot to complete the process" &
jamfHelper1
}


##########################
### script starts here ###
##########################

echo "Hardware UUID: $HardwareUUID"
echo "Local Items Keychain: $LocalKeychain"

if [[ $LoggedInUser != *"freelance"* ]]; then
  echo "Logged in user is not a freelance account so nothing to do"
  exit 1
else
  echo "freelance account logged in so prompting to reset the keychain..."
  jamfHelper_ResetKeychain 2>/dev/null
  if [[ "$?" != "0" ]]; then
	echo "User selected Cancel, Keychain will not be reset"
		jamfHelper_Cancelled
		exit 1
    else
      echo "User selected Reset, resetting Keychain..."
      #close all open apps
      echo "Killing all open applications for $LoggedInUser"
      killall -u $LoggedInUser
      echo "Deleting Login and Local Keychains..."
      deleteLoginKeychain
      deleteLocalKeychain
    fi
fi

confirmKeychainDeletion

jamfHelper_KeychainReset

sleep 10

killall jamfHelper

shutdown -r now

exit 0
