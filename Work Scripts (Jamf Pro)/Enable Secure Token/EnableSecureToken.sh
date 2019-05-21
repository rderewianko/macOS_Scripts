#!/bin/bash

########################################################################
#               Grant a SecureToken to the logged in user              #
#               Enable fileVault via a policy if required              #
################### Written by Phil Walker May 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Get the logged in users GUID
userGUID=$(dscl . list /Users GeneratedUID | grep "$loggedInUser" | head -n 1 | awk '{print $2}')
# Check if the logged in user is FileVault enabled already
userFVEnabled=$(fdesetup list | grep "$loggedInUser" | sed 's/.*,//g')
# Admin username
adminUser=admin
# Admin Password
adminUserPassword=D0ntL3t1tSl1p!
# Check local admin account has been created
adminAccount=$(dscl . list /Users | grep -v "_\|casadmin" | grep "admin" | sed -n 1p)
# FileVault status
fileVault=$(fdesetup status | grep "FileVault" | head -n 1)

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

function checkAdminAccount()
{
# Confirm that the local admin account exists and is an administrator
localAdmin=$(/usr/sbin/dseditgroup -o checkmember -m "$adminUser" admin | awk '/yes/ { print $1 }')
if [[ "$adminAccount" != "admin" ]];then
	echo "Local admin account not found, exiting script..."
	exit 1
else
	if [[ "$localAdmin" == "yes" ]]; then
			echo "Local admin account found and a member of administrators group"
		else
			echo "Local admin account found but not a member of the admin group"
			echo "Adding local admin to administrators group..."
			dseditgroup -o edit -a admin -t user admin
			if [[ $? -eq "0" ]]; then
				echo "Local admin added now added to administrators group"
			fi
	fi
fi

}

function checkAdminSecureToken()
{
# Check if the admin account has a secure token
adminSecureTokenStatus=$(/usr/sbin/sysadminctl -secureTokenStatus "$adminUser" 2>&1)
if [[ "$adminSecureTokenStatus" =~ "ENABLED" ]]; then
	localAdminSecureToken="Token"
	echo "Local admin account already has a SecureToken"
else
	localAdminSecureToken="NoToken"
	echo "Local admin account does NOT have a SecureToken"
fi
}

function checkUserSecureToken()
{
# Check the logged in users SecureToken status
userSecureTokenStatus=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
if [[ "$userSecureTokenStatus" =~ "ENABLED" ]]; then
	userSecureToken="Token"
	echo "$loggedInUser already has a SecureToken"
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

function promptUserPassword()
{
echo "Prompting $loggedInUser for their login password."
userPass=$(/usr/bin/osascript << EOT

set user_password to display dialog ¬
	"Please enter your BAUER-UK password to enable SecureToken:" with title ¬
	"Bauer IT" with icon caution ¬
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
}

#JamfHelper message to advise the customer of the process
function jamfHelper_EnableFileVault ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns -title "Message from Bauer IT" -heading "Enable Encryption" -description "Your MacBook must be encrypted due to GDPR requirements

Please enter your BAUER-UK password when prompted to enable your account for FileVault.

If you are the first user to enable their account you will be automatically logged out during the process, please log straight back in to complete the process"  -button1 "Start" -defaultButton 1

}

function fvDisabled() {
# If FileVault is disabled then call the policy to enable it
# Before enabling, double check that the logged in user has a SecureToken and is a FileVault enabled user
userFVEnabled=$(fdesetup list | grep "$loggedInUser" | sed 's/.*,//g')
userSecureTokenStatus=$(/usr/sbin/sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
if [[ "$userFVEnabled" == "$userGUID" ]] && [[ "$userSecureTokenStatus" =~ "ENABLED" ]]; then
	echo "$loggedInUser has a SecureToken and is a FileVault enabled user"
		#fdesetup remove -user "$adminUser"
		jamf policy -trigger EnableFileVaultIndividualUser
		killall loginwindow
		exit 0
	else
		echo "No user found to have a SecureToken, process FAILED"
		exit 1
	fi

}

########################################################################
#                         Script starts here                           #
########################################################################

checkLoggedInUser
checkAdminAccount
checkAdminSecureToken
checkUserSecureToken
checkFileVault

# If the logged in user has a SecureToken, is a FileVault enabled user and FileVault has already been enabled, do nothing

if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fvStatus" == "Enabled" ]]; then
	echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled, nothing to do!"
	exit 0
fi

jamfHelper_EnableFileVault

# Prompt for password
promptUserPassword

# Check if the password is correct
passDSCLCheck=$(dscl /Local/Default authonly $loggedInUser $userPass; echo $?)

# If password is not valid, loop and ask again
while [[ "$passDSCLCheck" != "0" ]]; do
		echo "Asking the user to enter the correct password"
			promptUserPassword
			passDSCLCheck=$(dscl /Local/Default authonly $loggedInUser $userPass; echo $?)
		done

			if [[ "$passDSCLCheck" -eq "0" ]]; then
				echo "Password confirmed for $loggedInUser"
			fi

# Neither the local admin account or the logged in user have a SecureToken.

# This will only work on a new Mac! If FIleVault has already been enabled by another user
# and the local admin account has had the SecureToken revoked to remove the account from
# preBoot, only the account with a SecureToken can grant further tokens. That account will
# need to have elevated privileges to do so.

if [[ "$localAdminSecureToken" == "NoToken" ]] && [[ "$userSecureToken" == "NoToken" ]]; then
	sysadminctl -adminUser $adminUser -adminPassword $adminUserPassword -secureTokenOn $loggedInUser -password $userPass
		if [[ $? -eq "0" ]]; then
			echo "SecureToken granted to both the local admin account and $loggedInUser"
		fi
			checkFileVault
				if [[ "$fvStatus" == "Enabled" ]] && [[ "$userFVEnabled" == "$userGUID" ]]; then
					#fdesetup remove -user "$adminUser"
					echo "FileVault already enabled. $loggedInUser has a SecureToken and is a FileVault enabled user"
					# If FileVault is already enabled update preBoot
					echo "Updating preBoot..."
					diskutil quiet apfs updatepreBoot /
				else
					fvDisabled
		fi
fi

# Only the Local admin account has a SecureToken

if [[ "$localAdminSecureToken" == "Token" ]] && [[ "$userSecureToken" == "NoToken" ]]; then
	sysadminctl -adminUser $adminUser -adminPassword $adminUserPassword -secureTokenOn $loggedInUser -password $userPass
		if [[ $? -eq "0" ]]; then
			echo "SecureToken granted to $loggedInUser"
		fi
			checkFileVault
				if [[ "$fvStatus" == "Enabled" ]] && [[ "$userFVEnabled" == "$userGUID" ]]; then
					#fdesetup remove -user "$adminUser"
					# If FileVault is already enabled update preBoot
					echo "Updating preBoot..."
					diskutil quiet apfs updatepreBoot /
				else
					fvDisabled
		fi
fi


# Only the logged in user has a SecureToken

# This would only happen if there are no other accounts with a UID greater than or equal to 500
# at the time the standard user account was created.

if [[ "$localAdminSecureToken" == "NoToken" ]] && [[ "$userSecureToken" == "Token" ]]; then
	echo "Elevating privileges for $loggedInUser to allow SecureToken to be granted to the local admin account"
	dseditgroup -o edit -a "$loggedInUser" -t user admin
		sysadminctl -adminUser $loggedInUser -adminPassword $userPass -secureTokenOn $adminUser -password $adminUserPassword
			if [ $? = 0 ]; then
				echo "SecureToken granted to the local admin account, removing admin rights from $loggedInUser"
			fi
				dseditgroup -o edit -d $loggedInUser -t user admin
					if [[ $? -eq "0" ]]; then
						echo "$loggedInUser removed from the admin group"
					fi
				fvDisabled
fi

exit 0
