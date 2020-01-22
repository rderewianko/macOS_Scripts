#!/bin/bash

########################################################################
#       Enable an additional user account for FileVault (10.14+)       #
################## Written by Phil Walker June 2019 ####################
########################################################################

# This script is designed to be used with or without Sophos Device
# Encryption. A jamfHelper window will ask the user which process to
# use based on if they have been prompted by Sophos Device Encryption
# or not

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get the logged user's real name
RealName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2}' | sed s/,//)
# FileVault status
fileVaultStatus=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)

########################################################################
#                            Functions                                 #
########################################################################

function promptForFVUser()
{
echo "Prompting for a FileVault enabled user's username"
fvEnabledUser=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set fv_user_name to display dialog ¬
	"Please enter the username of a FileVault enabled user" with title ¬
	"Bauer IT" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" ¬
	default answer ¬
	"" buttons {"Cancel", "Continue"} default button 2 cancel button 1 ¬
	giving up after 295 ¬

	if button returned of the result is "Cancel" then
return 1

	else if the button returned of the result is "Continue" then

	set text_fv_username to text returned of fv_user_name

end if

EOT
)
if [ "$?" != "0" ]; then
	exit 1
else
	echo "FileVault enabled user entered : $fvEnabledUser"
fi
}

function promptForFVUserPass()
{
echo "Prompting for ${fvEnabledUser}'s password"
fvEnabledUserPass=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set fv_user_password to display dialog ¬
	"Please enter the BAUER-UK password for ${fvEnabledUser}" with title ¬
	"Bauer IT" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" ¬
	default answer ¬
	"" buttons {"Cancel", "Continue"} default button 2 cancel button 1 ¬
	giving up after 295 ¬
	with hidden answer

	if button returned of the result is "Cancel" then
return 1

	else if the button returned of the result is "Continue" then

	set text_fv_password to text returned of fv_user_password

end if

EOT
)
if [ "$?" != "0" ]; then
	echo "Process cancelled"
	exit 1
fi
}

function promptForLoggedInUserPass()
{
echo "Prompting for ${loggedInUser}'s password"
loggedInUserPass=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set add_user_password to display dialog ¬
	"Please enter the BAUER-UK password for ${loggedInUser}" with title ¬
	"Bauer IT" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" ¬
	default answer ¬
	"" buttons {"Cancel", "Continue"} default button 2 cancel button 1 ¬
	giving up after 295 ¬
	with hidden answer

	if button returned of the result is "Cancel" then
return 1

	else if the button returned of the result is "Continue" then

	set text_the_password to text returned of add_user_password

end if

EOT
)
if [ "$?" != "0" ]; then
	exit 1
fi
}

function loggedInUserStatus ()
{
# Get the logged in users GUID
localUserGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')
# Get the logged in user's SecureToken status
localUserSecureToken=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
# Get the logged in user's FileVault status
localUserFVStatus=$(/usr/bin/fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')

if [[ "$localUserSecureToken" =~ "ENABLED" ]] && [[ "$localUserGUID" == "$localUserFVStatus" ]]; then
  echo "$loggedInUser already has a SecureToken and is a FileVault enabled user, nothing to do"
  	jamfHelperNothingToDo
  exit 0
else
  echo "${loggedInUser}'s account will now be enabled for FileVault"
	echo "-----------------------------------------------------------"
fi

}

function postLoggedInUserCheck ()
{
# Get the logged in users GUID
localUserGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')
# Get the logged in user's SecureToken status
localUserSecureToken=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
# Get the logged in user's FileVault status
localUserFVStatus=$(/usr/bin/fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')

if [[ "$localUserSecureToken" =~ "ENABLED" ]] && [[ "$localUserGUID" == "$localUserFVStatus" ]]; then
  echo "$loggedInUser now has a SecureToken and is a FileVault enabled user!"
  echo "Updating preBoot..."
  	diskutil quiet apfs updatepreBoot /
	echo "preBoot updated"
else
  echo "Something went wrong, unable to enable $loggedInUser for FileVault"
  	jamfHelperSomethingWentWrong
  exit 1
fi

}

function removeTempAdminRights() {
#Loop through each account found and remove from the admin group (excluding root, admin and casadmin).

#Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
for user in $adminUsers
	do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "casadmin" ]]; then
        dseditgroup -o edit -d $user -t user admin
        	if [[ $? -eq "0" ]]; then
						echo "Removed user $user from admin group"
					fi
  else
        	echo "Admin user $user left alone"
    	fi
done
}

#JamfHelper: Is the Sophos Device Encryption window open or not?
function jamfHelperSelection ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Enable another user for FileVault" -description "Is the Sophos Device Encryption pop-up window currently available?"  -button1 "Yes" -button2 "No" -defaultButton 1

}

#JamfHelper: User entered is not a FileVault enabled user
function jamfHelperNotFVUser ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title "Message from Bauer IT" -heading "Unable to Complete Process" -description "${fvEnabledUser} is not a FileVault enabled user.

Please make sure the username you enter is a FileVault enabled user"  -button1 "OK" -defaultButton 1

}

#JamfHelper: FileVault is disabled
function jamfHelperFVDisabled ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Unable to Complete Process" -description "FileVault is currently disabled.

This process cannot complete successfully until FileVault has been enabled

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1

}

function jamfHelperAdminFailed()
{
#Show jamfHelper message to advise process failed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Administrator Priviliges failed" -description "It looks like something went wrong when trying to change your account priviliges.

Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1
}

function jamfHelperEnterCreds() {

#Show jamfHelper message to advise admin rights removed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Enable another user for FileVault" -description "Please enter the credentials required in the Sophos Device Encryption window.

It is important that you do NOT reboot during this process.

Once completed $RealName will be able to unlock the disk for this MacBook" -button1 "Ok" -defaultButton 1

}

function jamfHelperComplete() {

#Show jamfHelper message to advise admin rights removed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Process Complete!" -description "$RealName can now unlock the disk for this MacBook." -button1 "Ok" -defaultButton 1

}

#JamfHelper: Process failed, contact IT support
function jamfHelperSomethingWentWrong ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title "Message from Bauer IT" -heading "Process Failed!" -description "Something went wrong.

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1

}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$fileVaultStatus" != "FileVault is On." ]]; then
	echo "FileVault disabled, please enable FileVault before running this policy again"
	jamfHelperFVDisabled
	exit 1
fi

jamfHelperSelection

	if [ "$?" = "0" ]; then
		echo "Sophos Device Encryption prompt currenly open, using SDE process to enable another user for FileVault"

########################################################################
#                  Sophos Device Encryption Process                    #
########################################################################

		promptForFVUser

# Get the FV enabled users GUID
fvUserGUID=$(/usr/bin/dscl . -read /Users/$fvEnabledUser GeneratedUID | awk '{print $2}')
# Get the FV enabled user's SecureToken status
fvUserSecureToken=$(/usr/sbin/sysadminctl -secureTokenStatus "$fvEnabledUser" 2>&1)
# Get the FV enabled user's FileVault status
fvUserStatus=$(/usr/bin/fdesetup list | grep "$fvEnabledUser" | awk  -F, '{print $2}')

		echo "FileVault is on, checking ${fvEnabledUser}'s SecureToken and FileVault status"
			if [[ "$fvUserSecureToken" =~ "ENABLED" ]] && [[ "$fvUserGUID" == "$fvUserStatus" ]]; then
				echo "$fvEnabledUser has a SecureToken and is a FileVault enabled user, continuing..."
  		else
	  		echo "$fvEnabledUser is not a FileVault enabled user! Exiting..."
    			jamfHelperNotFVUser
	  		exit 1
  		fi

		echo "Granting temporary admin rights for $fvEnabledUser to allow SecureToken to be granted to $loggedInUser"
			dseditgroup -o edit -a "$fvEnabledUser" -t user admin

#Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

#Check if the FV enabled user is in the admin group and show jamfHelper message
		if [[ "$adminUsers" =~ "$fvEnabledUser" ]]; then
			echo "$LoggedInUser is now an admin"
		else
			echo "Temp admin process failed"
				jamfHelperAdminFailed
				exit 1
		fi

		jamfHelperEnterCreds

		sleep 60

		removeTempAdminRights

# Get the logged in users GUID
UserGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')
# Get the logged in users FileVault status
UserFVStatus=$(/usr/bin/fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')

		if [[ "$UserGUID" == "$UserFVStatus" ]]; then
			echo "$loggedInUser now has a SecureToken and is a FileVault enabled user"
				jamfHelperComplete
				exit 0
		else
			echo "Something went wrong $loggedInUser is not a FileVault enabled user!"
				jamfHelperSomethingWentWrong
				exit 1
		fi

else
	echo "Sophos Device Encryption prompt not open, using manual process to enable another user for FileVault"

########################################################################
#                          Manual Process                              #
########################################################################

	promptForFVUser

# Get the FV enabled users GUID
fvUserGUID=$(/usr/bin/dscl . -read /Users/$fvEnabledUser GeneratedUID | awk '{print $2}')
# Get the FV enabled user's SecureToken status
fvUserSecureToken=$(/usr/sbin/sysadminctl -secureTokenStatus "$fvEnabledUser" 2>&1)
# Get the FV enabled user's FileVault status
fvUserStatus=$(/usr/bin/fdesetup list | grep "$fvEnabledUser" | awk  -F, '{print $2}')

		echo "FileVault is on, checking ${fvEnabledUser}'s SecureToken and FileVault status"
			if [[ "$fvUserSecureToken" =~ "ENABLED" ]] && [[ "$fvUserGUID" == "$fvUserStatus" ]]; then
				echo "$fvEnabledUser has a SecureToken and is a FileVault enabled user, continuing..."
	  	else
		  	echo "$fvEnabledUser is not a FileVault enabled user! Exiting..."
	    		jamfHelperNotFVUser
		  		exit 1
	  	fi

			promptForFVUserPass

# Check if the password is correct for the FileVault enabled user
passDSCLCheck=$(dscl /Local/Default authonly $fvEnabledUser $fvEnabledUserPass; echo $?)

# If password is not valid, loop and ask again
		while [[ "$passDSCLCheck" != "0" ]]; do
			echo "Asking the user to enter the correct password"
	  		promptForFVUserPass
	  		passDSCLCheck=$(dscl /Local/Default authonly $fvEnabledUser $fvEnabledUserPass; echo $?)
		done

				if [[ "$passDSCLCheck" == "0" ]]; then
	 				echo "Password confirmed for $fvEnabledUser"
	 			fi

				promptForLoggedInUserPass

# Check if the logged in users password is correct
passDSCLCheckLoggedInUser=$(dscl /Local/Default authonly $loggedInUser $loggedInUserPass; echo $?)

# If password is not valid, loop and ask again
		while [[ "$passDSCLCheckLoggedInUser" != "0" ]]; do
			echo "Asking the user to enter the correct password"
				promptForLoggedInUserPass
	  		passDSCLCheckLoggedInUser=$(dscl /Local/Default authonly $loggedInUser $loggedInUserPass; echo $?)
		done

			if [[ "$passDSCLCheckLoggedInUser" == "0" ]]; then
	  		echo "Password confirmed for $loggedInUser"
	  	fi

			loggedInUserStatus

			echo "Granting temporary admin rights for $fvEnabledUser to allow SecureToken to be granted to $loggedInUser"
				dseditgroup -o edit -a "$fvEnabledUser" -t user admin
			echo "Granting $loggedInUser a Secure Token..."
	  		sysadminctl -adminUser $fvEnabledUser -adminPassword $fvEnabledUserPass -secureTokenOn $loggedInUser -password $loggedInUserPass

			echo "Checking the process completed successfully"
				postLoggedInUserCheck

			echo "Removing temporary admin rights from $fvEnabledUser"
				removeTempAdminRights

				jamfHelperComplete

fi

exit 0
