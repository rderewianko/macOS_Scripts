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
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
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
imagePath="/usr/local/BauerMediaGroup/FileVaultReissue/Bauer-Logo-icons1.png"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
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
    # Check if the screen is locked
    lockScreenStatus=$(runAsUser /usr/bin/python -c 'import sys,Quartz; d=Quartz.CGSessionCopyCurrentDictionary(); print d' | grep "CGSSessionScreenIsLocked")
    # If the lockScreenStatus check is not empty, then the screensaver is on or the screen is locked
    if [[ -n "$lockScreenStatus" ]]; then
        echo "${loggedInUser} is logged in, but the screen is locked, or the screensaver is active."
        echo "Policy will run again tomorrow, exiting"
        exit 0
    else
        echo "${loggedInUser} is logged in, and the screen is not locked. Continuing..."
        checkUserSecureToken
        checkFileVault
        # Confirm that FileVault is on and the logged in user has a SecureToken and is FileVault enabled
        # If the logged in user has a SecureToken, is a FileVault enabled user and FileVault has already been enabled, start the process
        if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fvStatus" == "Enabled" ]]; then
            echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled"
            # Confirm the content is there
            if [[ -d "$filevaultReissue" ]] && [[ -f "$imagePath" ]]; then
                echo "Opening Filevault Reissue..."
                # App must be run as root or another admin user
                "$appBinary"
                echo "Waiting for user interaction..."
                echo "If after 5 minutes the app is closed an inventory update will be run"
                echo "If the app is still open it will be automatically closed and the policy will run again tomorrow"
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
fi
exit 0