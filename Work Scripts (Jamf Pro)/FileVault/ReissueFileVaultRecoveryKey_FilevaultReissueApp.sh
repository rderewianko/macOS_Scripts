#!/bin/zsh

########################################################################
#  Issue a new FileVault Recovery Key using the Filevault Reissue App  #
################### Written by Phil Walker Nov 2020 ####################
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
# FileVault status
fileVaultStatus=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)
# FileVault Reissue
filevaultReissue="/private/var/tmp/Filevault Reissue.app"
# FileVault Reissue app binary
appBinary="/private/var/tmp/Filevault Reissue.app/Contents/MacOS/Filevault Reissue"
# Bauer logo
imagePath="/usr/local/bauer/loginwindow/Bauer-Logo-icons1.png"

########################################################################
#                            Functions                                 #
########################################################################

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
if [[ "$fileVaultStatus" == "FileVault is On." ]]; then
	userFVEnabled=$(fdesetup list | grep "$loggedInUser" | sed 's/.*,//g')
	fvStatus="Enabled"
	echo "FileVault already enabled"
else
	fvStatus="Disabled"
	echo "FileVault is currently disabled"
fi
}

function cleanUp ()
{
if [[ -d "$filevaultReissue" ]]; then
    rm -rf "$filevaultReissue"
    if [[ ! -d "$filevaultReissue" ]]; then
        echo "Temporary content cleaned up"
    else
        echo "Failed to cleanup temporary content"
    fi
fi 
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    exit 0
else
    checkUserSecureToken
    checkFileVault
    # Confirm that FileVault is on and the logged in user has a SecureToken and is FileVault enabled
    # If the logged in user has a SecureToken, is a FileVault enabled user and FileVault has already been enabled, start the process
    if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fvStatus" == "Enabled" ]]; then
        echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled"
        # Confirm the content is there
        if [[ -d "$filevaultReissue" ]] && [[ -f "$imagePath" ]]; then
            echo "Opening Filevault Reissue"
            "$appBinary"
            # sleep for 5 minutes to allow time for the user to enter their credentials
            /bin/sleep 300
            # If the user hasn't interacted with the application force it to close so that the policy can run again the following day
            fvReissueProcess=$(pgrep "Filevault Reissue")
            if [[ "$fvReissueProcess" != "" ]]; then
                /usr/bin/pkill -9 "Filevault Reissue"
                echo "Filevault Reissue application closed"
            else
                echo "Filevault Reissue application closed by the user" 
                # Run recon twice to make sure the new key is available in Jamf Pro
                /usr/local/jamf/bin/jamf recon
                /usr/local/jamf/bin/jamf recon
            fi
            cleanUp
        else
            echo "Required content not found"
            cleanUp
            exit 1
        fi
    else
        echo "Requirements not met!"
        echo "SecureToken Status for ${loggedInUser}: ${userSecureToken}"
        echo "FileVault Status: ${fvStatus}"
        cleanUp
        exit 1
    fi
fi
exit 0