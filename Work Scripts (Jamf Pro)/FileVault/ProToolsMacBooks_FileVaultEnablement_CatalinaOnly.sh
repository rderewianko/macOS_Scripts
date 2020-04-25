#!/bin/bash

########################################################################
#        Pro Tools MacBooks FileVault Enablement (macOS 10.15+)        #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
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
# Check if the Mac is currently being enrolled
depNotify=$(ps aux | grep -v grep | grep "DEPNotify.app")
# jamf Helper
jamfHelper=/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper

########################################################################
#                            Functions                                 #
########################################################################

function checkAdminSecureToken ()
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

function checkUserSecureToken ()
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

function checkFileVault ()
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

function checkManagementAccount ()
{
# Confirm that the management account is no longer a FileVault enabled user
# Get the management account user GUID
managementGUID=$(/usr/bin/dscl . -read /Users/${adminUser} GeneratedUID | awk '{print $2}')
# List FileVault enabled users
fvEnabled=$(/usr/bin/fdesetup list)
if [[ "$fvEnabled" =~ "$managementGUID" ]]; then
	echo "Management account still FileVault enabled"
	echo "Manual clean up required to remove account from preBoot"
else
	echo "Management account no longer FileVault enabled"
fi
}

function promptUserPassword ()
{
echo "Prompting $loggedInUser for their login password."
userPass=$(su - $loggedInUser -c /usr/bin/osascript << EOT

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
	echo "$loggedInUser clicked cancel, the policy will run again tomorrow"
	exit 0
fi
}

function jamfHelperFullScreen ()
# Full screen jamf Helper to advise that a logout is required to start the encryption process
{
su - $loggedInUser <<'jamfmsg'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns -title "Message from Bauer IT" -heading "Disk encryption is waiting to be enabled" -alignHeading center -description "Disk encryption is a GDPR requirement for all Bauer MacBooks

When prompted, please enter your password to start the process" &

jamfmsg
}

# Jamf Helper message to advise the process was successful
function jamfHelperSuccess ()
{

helperSuccess=$("$jamfHelper" -windowType utility \
-icon /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns \
-title "Message from Bauer IT" -heading "Disk Encryption" \
-description "You will now be automatically logged out

Please log back in and accept the prompts to enable FileVault" -timeout 20 -button1 "Done" -defaultButton 1)

}

# Jamf Helper: Process failed, contact IT support
function jamfHelperSomethingWentWrong ()
{

helperFailure=$("$jamfHelper" -windowType utility \
-icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns \
-title "Message from Bauer IT" -heading "Process Failed!" \
-description "Something went wrong

Please contact the IT Service Desk for assistance"  -button1 "OK" -defaultButton 1)

}

function enableFileVault ()
{
#Create deferral plist
cat > /usr/local/bin/FileVaultEnablement.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Username</key>
    <string></string>
    <key>Password</key>
    <string></string>
</dict>
</plist>
EOF
#Set correct permissions
/usr/sbin/chown root:wheel /usr/local/bin/FileVaultEnablement.plist
/bin/chmod 644 /usr/local/bin/FileVaultEnablement.plist

#Enable FileVault at next login
fdesetup enable -defer /usr/local/bin/FileVaultEnablement.plist -forceatlogin 0 –dontaskatlogout

#Submit inventory to Jamf Pro
/usr/local/jamf/bin/jamf recon
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, exiting"
    exit 0
elif [[ "$depNotify" != "" ]]; then
    echo "Mac currently being enrolled, exiting"
    exit 0
else
    checkAdminSecureToken
    checkUserSecureToken
    checkFileVault
# If the logged in user has a SecureToken, is a FileVault enabled user and FileVault has already been enabled, do nothing
    if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fvStatus" == "Enabled" ]]; then
        echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled, nothing to do!"
	    jamfHelperNothingToDo
	    exit 0
    else
        # Display full screen jamf Helper
        jamfHelperFullScreen
        sleep 20s
        #Kill the full screen jamf Helper
        killall jamfHelper
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
        # Only the Management account has a SecureToken so must be used to grant the logged in user a token or no one has a SecureToken
	    if [[ "$localAdminSecureToken" == "Token" ]] && [[ "$userSecureToken" == "NoToken" ]] || [[ "$localAdminSecureToken" == "NoToken" ]] && [[ "$userSecureToken" == "NoToken" ]]; then
		    sysadminctl -adminUser $adminUser -adminPassword $adminUserPassword -secureTokenOn $loggedInUser -password $userPass
			checkUserSecureToken
				if [[ "$userSecureToken" == "Token" ]]; then
					/usr/bin/fdesetup remove -user "$adminUser"
					checkManagementAccount
					enableFileVault
                    jamfHelperSuccess
					#Kill the loginwindow to force a login
					killall loginwindow
				else
					echo "Process FAILED!"
					jamfHelperSomethingWentWrong
					exit 1
				fi
	    fi
    fi
fi

exit 0
