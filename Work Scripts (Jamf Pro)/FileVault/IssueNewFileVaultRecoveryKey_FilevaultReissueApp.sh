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
userGUID=$(dscl . -read /Users/"$loggedInUser" GeneratedUID | awk '{print $2}')
# Check if the logged in user is FileVault enabled already
userFVEnabled=$(fdesetup list | grep "$loggedInUser" | awk -F, '{print $2}')
# Check the logged in users Secure Token status
secureTokenStatus=$(sysadminctl -secureTokenStatus "$loggedInUser" 2>&1)
if [[ "$secureTokenStatus" =~ "ENABLED" ]]; then
	userSecureToken="Token"
else
	userSecureToken="NoToken"
fi
# FileVault status
fileVaultStatus=$(fdesetup status | awk '/FileVault is/{print $3}' | tr -d .)
# FileVault Reissue
filevaultReissue="/private/var/tmp/Filevault Reissue.app"
# FileVault Reissue app binary
appBinary="/private/var/tmp/Filevault Reissue.app/Contents/MacOS/Filevault Reissue"
# Bauer logo
imagePath="/usr/local/BauerMediaGroup/FileVaultReissue/Bauer-Logo-icons1.png"
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf Helper icon
helperIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"
# Temporary directory
tempDir="/usr/local/BauerMediaGroup/FileVaultReissue"

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

function jamfHelperFullScreen ()
# Fullscreen jamf Helper to try and force the user to take action
{
"$jamfHelper" -windowType fs -icon "$helperIcon" -heading "Valid FileVault Recovery Key Not Found!" \
-description "A valid FileVault Recovery Key is required to enable Bauer Technology to unlock your Mac should you experience any issues with your password

When prompted, please enter your username and password to issue a new FileVault Recovery Key" &
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

# Make sure the content directory is hidden
chflags hidden "$tempDir"
# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    cleanUp
    exit 0
else
    # Check if the screen is locked
    lockScreenStatus=$(runAsUser /usr/bin/python -c 'import sys,Quartz; d=Quartz.CGSessionCopyCurrentDictionary(); print d' | grep "CGSSessionScreenIsLocked")
    # If the lockScreenStatus check is not empty, then the screensaver is on or the screen is locked
    if [[ -n "$lockScreenStatus" ]]; then
        echo "${loggedInUser} is logged in, but the screen is locked or the screensaver is active."
        echo "Policy will run again later, exiting"
        exit 0
    else
        echo "${loggedInUser} is logged in, and the screen is not locked. Continuing..."
        # Confirm that FileVault is on, the logged in user has a SecureToken and is FileVault enabled
        # If the logged in user has a Secure Token, is a FileVault enabled user and FileVault has already been enabled, start the process
        if [[ "$userSecureToken" == "Token" ]] && [[ "$userGUID" == "$userFVEnabled" ]] && [[ "$fileVaultStatus" == "On" ]]; then
            echo "$loggedInUser has a SecureToken, is a FileVault enabled user and FileVault is enabled"
            # Confirm the content is there
            if [[ -d "$filevaultReissue" ]] && [[ -f "$imagePath" ]]; then
                # Display full screen jamf Helper
                echo "Displaying fullscreen Jamf Helper message"
                jamfHelperFullScreen
                sleep 20
                # Kill the full screen jamf Helper
                killall -13 jamfHelper 2>/dev/null
                echo "Opening Filevault Reissue..."
                # App must be run as root or another admin user
                "$appBinary" &
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