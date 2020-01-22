#!/bin/bash

########################################################################
#       Grant a SecureToken to the logged in user (10.15 only)         #
################### Written by Phil Walker Jan 2020 ####################
########################################################################
# Required when the standard process has not been followed, resulting in
# the management account being the only user with a SecureToken

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Get the logged in users GUID
userGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')
# Check if the logged in user is FileVault enabled already
userFVEnabled=$(/usr/bin/fdesetup list | grep "$loggedInUser" | sed 's/.*,//g')
# Admin username. Value set in Parameter 4 in the policy
adminUser=$4
# Admin Password. Value set in Parameter 5 in the policy
adminUserPassword=$5
# FileVault status
fileVault=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)

########################################################################
#                            Functions                                 #
########################################################################

function checkLoggedInUser ()
{
# Confirm the logged in user is not _mbsetupuser before continuing
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "_mbsetupuser" ]]; then
	echo "No user logged in"
	exit 1
else
		echo "$loggedInUser is logged in"
fi
}

function checkAdminSecureToken()
{
# Check if the admin account has a SecureToken
adminSecureTokenStatus=$(/usr/sbin/sysadminctl -secureTokenStatus "$adminUser" 2>&1)
if [[ "$adminSecureTokenStatus" =~ "ENABLED" ]]; then
	localAdminSecureToken="Token"
	echo "Management account has a SecureToken"
else
	localAdminSecureToken="NoToken"
	echo "Management account does NOT have a SecureToken"
fi
}

function checkUserSecureToken()
{
# Check the logged in users SecureToken status
userSecureTokenStatus=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
if [[ "$userSecureTokenStatus" =~ "ENABLED" ]]; then
	userSecureToken="Token"
	echo "$loggedInUser has a SecureToken"
else
	userSecureToken="NoToken"
	echo "$loggedInUser does NOT have a SecureToken"
fi
}

function checkFileVault()
{
# Check if FileVault has already been enabled
if [[ "$fileVault" == "FileVault is On." ]]; then
	userFVEnabled=$(fdesetup list | grep "$loggedInUser" | sed 's/.*,//g')
	fvStatus="Enabled"
	echo "FileVault already enabled"
else
	fvStatus="Disabled"
	echo "FileVault is currently disabled"
fi
}

function checkManagementAccount()
{
# Confirm that the management account is no longer a FileVault enabled user
# Get the management account user GUID
managementGUID=$(/usr/bin/dscl . -read /Users/casadmin GeneratedUID | awk '{print $2}')
# List FileVault enabled users
fvEnabled=$(/usr/bin/fdesetup list)
if [[ "$fvEnabled" =~ "$managementGUID" ]]; then
	echo "Management account still FileVault enabled"
	echo "Manual clean up required to remove account from preBoot"
else
	echo "Management account no longer FileVault enabled"
fi
}

function promptUserPassword()
{
echo "Prompting $loggedInUser for their login password."
userPass=$(/usr/bin/osascript << EOT

set user_password to display dialog ¬
	"Please enter your BAUER-UK password" with title ¬
	"Bauer IT" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" ¬
	default answer ¬
	"" buttons {"Cancel", "Continue"} default button 2 cancel button 1 ¬
	giving up after 295 ¬
	with hidden answer

	if button returned of the result is "Cancel" then
return 1

	else if the button returned of the result is "Continue" then

	set text_my_password to text returned of user_password

end if

EOT
)
if [ "$?" != "0" ]; then
	exit 1
fi
}

# JamfHelper message to advise no changes are required
function jamfHelperNothingToDo ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Disk Encryption" -description "FileVault already on and $loggedInUser is a FileVault enabled user

No further changes required"  -button1 "Done" -defaultButton 1

}

# JamfHelper message to advise the process was successful
function jamfHelperSuccess ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Disk Encryption" -description "SecureToken granted successfully

FileVault can now be enabled"  -button1 "Done" -defaultButton 1

}

# JamfHelper: Process failed, contact IT support
function jamfHelperSomethingWentWrong ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title "Message from Bauer IT" -heading "Process Failed!" -description "Something went wrong

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1

}

########################################################################
#                         Script starts here                           #
########################################################################

checkLoggedInUser
checkAdminSecureToken
checkUserSecureToken
checkFileVault

# If the logged in user has a SecureToken, is a FileVault enabled user and FileVault has already been enabled, do nothing

if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fvStatus" == "Enabled" ]]; then
	echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled, nothing to do!"
	jamfHelperNothingToDo
	exit 0

else

	echo "Starting process to grant $loggedInUser with a SecureToken before FileVault is enabled"

# Prompt for password
	promptUserPassword

# Check if the password is correct
	passDSCLCheck=$(/usr/bin/dscl /Local/Default authonly $loggedInUser $userPass; echo $?)

# If password is not valid, loop and ask again
	while [[ "$passDSCLCheck" != "0" ]]; do
		echo "Asking the user to enter the correct password"
			promptUserPassword
			passDSCLCheck=$(/usr/bin/dscl /Local/Default authonly $loggedInUser $userPass; echo $?)
		done

			if [[ "$passDSCLCheck" -eq "0" ]]; then
				echo "Password confirmed for $loggedInUser"
			fi

# Only the Management account has a SecureToken so must be used to grant the logged in user a token

	if [[ "$localAdminSecureToken" == "Token" ]] && [[ "$userSecureToken" == "NoToken" ]]; then
		sysadminctl -adminUser $adminUser -adminPassword $adminUserPassword -secureTokenOn $loggedInUser -password $userPass
			checkUserSecureToken
				if [[ "$userSecureToken" == "Token" ]]; then
						/usr/bin/fdesetup remove -user "$adminUser"
						checkManagementAccount
						/usr/local/jamf/bin/jamf recon
						jamfHelperSuccess
				else
					echo "Process FAILED!"
						jamfHelperSomethingWentWrong
					exit 1
				fi
	fi

fi

exit 0
