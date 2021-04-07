#!/bin/zsh

########################################################################
#       Enable an additional user account for FileVault (10.14+)       #
################## Written by Phil Walker June 2019 ####################
########################################################################
# Edit Mar 2021

########################################################################
#                            Variables                                 #
########################################################################
############ Variables for Jamf Pro Parameters - Start #################
# Management account username
mngmtAccount="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# FileVault status
fileVaultStatus=$(fdesetup status | awk '/FileVault is/{print $3}' | tr -d .)
# Mac model - marketing name
macModel=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf Helper title
helperTitle="Message from Bauer Technology"
# Jamf Helper icons
helperIconFV="/System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns"
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"

########################################################################
#                            Functions                                 #
########################################################################

function promptForFVUser ()
{
echo "Prompting for a FileVault enabled user's username"
fvEnabledUser=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set fv_user_name to display dialog ¬
	"Please enter the username of a FileVault enabled user (all lowercase)" with title ¬
	"Message from Bauer Technology" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" ¬
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
promptResult="$?"
if [[ "$promptResult" != "0" ]]; then
	echo "Cancel selected by the user, no changes made"
	exit 0
else
	echo "FileVault enabled user entered : $fvEnabledUser"
fi
}

function promptForFVUserPass ()
{
echo "Prompting for ${fvEnabledUser}'s password"
fvEnabledUserPass=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set fv_user_password to display dialog ¬
	"Please enter the BAUER-UK password for ${fvEnabledUser}" with title ¬
	"Message from Bauer Technology" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" ¬
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
promptResult="$?"
if [[ "$promptResult" != "0" ]]; then
	echo "Cancel selected by the user, no changes made"
	exit 0
fi
}

function promptForLoggedInUserPass ()
{
echo "Prompting for ${loggedInUser}'s password"
loggedInUserPass=$(su - $loggedInUser -c /usr/bin/osascript << EOT

set add_user_password to display dialog ¬
	"Please enter the BAUER-UK password for ${loggedInUser}" with title ¬
	"Message from Bauer Technology" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" ¬
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
promptResult="$?"
if [[ "$promptResult" != "0" ]]; then
	echo "Cancel selected by the user, no changes made"
	exit 0
fi
}

# Find correct format for real name of logged in user
function getRealName ()
{
# If Jamf Connect is installed try to get the value from the Jamf Connect state settings
if [[ -f "/Users/${loggedInUser}/Library/Preferences/com.jamf.connect.state.plist" ]]; then
	userRealName=$(sudo -u "$loggedInUser" defaults read com.jamf.connect.state UserCN 2>/dev/null)
	if [[ "$userRealName" == "" ]]; then
		# If no value is found then use the value from Directory Service
		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $2, $1}' | xargs)
	fi
else
	# Logged in users ID
	loggedInUserID=$(id -u "$loggedInUser")
	if [[ "$loggedInUser" =~ "admin" ]];then
		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $1, $2, $3}' | xargs)
	else
		if [[ "$loggedInUserID" -lt "1000" ]]; then
			userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $1, $2}' | xargs)
  		else
    		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $2, $1}' | xargs)
  		fi
	fi
fi
}

function loggedInUserStatus ()
{
# Get the logged in users GUID
loggedInUserGUID=$(dscl . -read /Users/"$loggedInUser" GeneratedUID | awk '{print $2}')
# Get the logged in user's Secure Token status
loggedInUserSecureToken=$(sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
# Get the logged in user's FileVault status
loggedInUserFVStatus=$(fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')
if [[ "$loggedInUserSecureToken" =~ "ENABLED" ]] && [[ "$loggedInUserGUID" == "$loggedInUserFVStatus" ]]; then
  	echo "${loggedInUser} already has a Secure Token and is a FileVault enabled user, nothing to do"
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
loggedInUserGUID=$(dscl . -read /Users/"$loggedInUser" GeneratedUID | awk '{print $2}')
# Get the logged in user's Secure Token status
loggedInUserSecureToken=$(sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
# Get the logged in user's FileVault status
loggedInUserFVStatus=$(fdesetup list | grep "$loggedInUser" | awk  -F, '{print $2}')
if [[ "$loggedInUserSecureToken" =~ "ENABLED" ]] && [[ "$loggedInUserGUID" == "$loggedInUserFVStatus" ]]; then
  	echo "${loggedInUser} now has a Secure Token and is a FileVault enabled user!"
  	echo "Updating preBoot..."
  	diskutil quiet apfs updatepreBoot /
	echo "preBoot updated"
else
  	echo "Something went wrong, unable to enable $loggedInUser for FileVault"
  	jamfHelperSomethingWentWrong
  	exit 1
fi
}

function removeTempAdminRights ()
{
# Loop through each account found and remove from the admin group (excluding root, admin and casadmin).

# Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
for user in ${(z)adminUsers}; do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "$mngmtAccount" ]]; then
        dseditgroup -o edit -d "$user" -t user admin
		commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
			echo "Removed ${user} from admin group"
		fi
    fi
done
}

# Jamf Helper: User entered is not a FileVault enabled user
function jamfHelperNotFVUser ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Unable to Complete Process" \
-description "${fvEnabledUser} is not a FileVault enabled user.

Please make sure the username you enter is a FileVault enabled user"  -button1 "OK" -defaultButton 1
}

# Jamf Helper: FileVault is disabled
function jamfHelperFVDisabled ()
{
"$jamfHelper" -windowType utility -icon "$helperIconFV" -title "$helperTitle" -heading "Unable to Complete Process" \
-description "FileVault is currently disabled.

This process cannot complete successfully until FileVault has been enabled

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1
}

# Jamf Helper: process failed
function jamfHelperAdminFailed ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Administrator Priviliges failed" \
-description "It looks like something went wrong when trying to change your account priviliges.

Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1
}

# Jamf Helper message to advise the process has started
function jamfHelperProgress ()
{
"$jamfHelper" -windowType utility -icon "$helperIconFV" -title "$helperTitle" \
-description "${userRealName}'s account is now being enabled for FileVault..." -alignDescription natural &
}

# Jamf Helper: process complete
function jamfHelperComplete () 
{
"$jamfHelper" -windowType utility -icon "$helperIconFV" -title "$helperTitle" -heading "Process Complete! ✅" \
-description "${userRealName} is now FileVault enabled for this ${macModel}" -button1 "Ok" -defaultButton 1
}

function jamfHelperNothingToDo ()
{
"$jamfHelper" -windowType utility -icon "$helperIconFV" -title "$helperTitle" -heading "No Changes Required ✅" \
-description "${userRealName} can already unlock the disk for this ${macModel}" -button1 "Ok" -defaultButton 1
}

# Jamf Helper: Process failed, contact IT support
function jamfHelperSomethingWentWrong ()
{
"$jamfHelper" -windowType utility -icon "$helperIconAlert" -title "$helperTitle" -heading "Process Failed!" \
-description "⚠️ Something went wrong ⚠️

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$fileVaultStatus" == "Off" ]]; then
	echo "FileVault is off, please enable FileVault before running this policy again"
	jamfHelperFVDisabled
	exit 1
else
	# Get the correctly formatted user real name
	getRealName
	echo "FileVault is on, starting process to enable ${loggedInUser} for FileVault..."
	# Prompt a FileVault enabled users username
	promptForFVUser
	echo "Checking ${fvEnabledUser}'s Secure Token and FileVault status"
	# Get the FV enabled users GUID
	fvUserGUID=$(dscl . -read /Users/"$fvEnabledUser" GeneratedUID | awk '{print $2}')
	# Get the FV enabled user's Secure Token status
	fvUserSecureToken=$(sysadminctl -secureTokenStatus "$fvEnabledUser" 2>&1)
	# Get the FV enabled user's FileVault status
	fvUserStatus=$(fdesetup list | grep "$fvEnabledUser" | awk  -F, '{print $2}')
	if [[ "$fvUserSecureToken" =~ "ENABLED" ]] && [[ "$fvUserGUID" == "$fvUserStatus" ]]; then
		echo "$fvEnabledUser has a Secure Token and is a FileVault enabled user, continuing..."
	else
		echo "$fvEnabledUser is not a FileVault enabled user! Exiting..."
		jamfHelperNotFVUser
	  	exit 1
	fi
	# Prompt for the FileVault enabled users password
	promptForFVUserPass
	# Check if the password is correct for the FileVault enabled user
	passDSCLCheck=$(dscl /Local/Default authonly "$fvEnabledUser" "$fvEnabledUserPass"; echo $?)
	# If password is not valid, loop and ask again
	while [[ "$passDSCLCheck" != "0" ]]; do
		echo "Asking the user to enter the correct password"
		  	promptForFVUserPass
			passDSCLCheck=$(dscl /Local/Default authonly "$fvEnabledUser" "$fvEnabledUserPass"; echo $?)
	done
	if [[ "$passDSCLCheck" == "0" ]]; then
	 	echo "Password confirmed for $fvEnabledUser"
	fi
	# Prompt for the logged in users password
	promptForLoggedInUserPass
	# Check if the logged in users password is correct
	passDSCLCheckLoggedInUser=$(dscl /Local/Default authonly "$loggedInUser" "$loggedInUserPass"; echo $?)
	# If password is not valid, loop and ask again
	while [[ "$passDSCLCheckLoggedInUser" != "0" ]]; do
		echo "Asking the user to enter the correct password"
		promptForLoggedInUserPass
	  	passDSCLCheckLoggedInUser=$(dscl /Local/Default authonly "$loggedInUser" "$loggedInUserPass"; echo $?)
	done
	if [[ "$passDSCLCheckLoggedInUser" == "0" ]]; then
	  	echo "Password confirmed for $loggedInUser"
	fi
	# Check the logged in users FileVault status
	loggedInUserStatus
	# Show a helper window to advise the process has started
	jamfHelperProgress
	# Make the FileVault enabled user an admin
	echo "Granting temporary admin rights for ${fvEnabledUser} to allow Secure Token to be granted to ${loggedInUser}"
	dseditgroup -o edit -a "$fvEnabledUser" -t user admin
	# Get a list of users who are in the admin group
	adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
	# Check if the FV enabled user is in the admin group and show jamfHelper message if not
	if [[ "$adminUsers" =~ $fvEnabledUser ]]; then
		echo "$fvEnabledUser is now an admin"
	else
		echo "Temp admin process failed"
		jamfHelperAdminFailed
		exit 1
	fi
	# Grant the logged in user a Secure Token
	echo "Granting $loggedInUser a Secure Token..."
	sysadminctl -adminUser "$fvEnabledUser" -adminPassword "$fvEnabledUserPass" -secureTokenOn "$loggedInUser" -password "$loggedInUserPass"
	echo "Checking the process completed successfully"
	# Check the process was successful
	postLoggedInUserCheck
	echo "Removing temporary admin rights from ${fvEnabledUser}"
	# Remove temp admin rights from the original FileVault enabled user
	removeTempAdminRights
	# Kill in progress helper window
	killall -13 jamfHelper 2>/dev/null
	# Helper to show its complete
	jamfHelperComplete
fi
exit 0