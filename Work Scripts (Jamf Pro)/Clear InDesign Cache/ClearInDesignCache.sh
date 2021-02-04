#!/bin/zsh

########################################################################
#                     Clear Adobe InDesign Cache                       #
################### Written by Phil Walker Jan 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################
############ Variables for Jamf Pro Parameters - Start #################
# InDesign application e.g. /Applications/Adobe InDesign CC 2019/Adobe InDesign CC 2019.app
appPath="$4"
############ Variables for Jamf Pro Parameters - End ###################
# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# InDesign cache directories
cacheDir1="/Users/$loggedInUser/Library/Caches/Adobe InDesign"
cacheDir2="/Users/$loggedInUser/Library/Caches/com.adobe.InDesign"
# Adobe InDesign process
idProc=$(pgrep InDesign)

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

########################################################################
#                         Script starts here                           #
########################################################################

# If InDesign is open, close it
if [[ "$idProc" != "" ]]; then
    echo "Closing InDesign..."
    pkill "InDesign"
    # Wait 5 seconds for app to close
    sleep 5
else
    echo "InDesign not open"
fi
# Delete cache
echo "Deleting InDesign cache for ${loggedInUser}..."
if [[ -d "$cacheDir1" ]]; then
	rm -rf "$cacheDir1"
	rm -rf "$cacheDir2" 2>/dev/null
    if [[ ! -d "$cacheDir1" ]]; then
        echo "InDesign cache cleared for $loggedInUser"
    else
        echo "Failed to clear InDesign cache for $loggedInUser"
        exit 1
    fi
else
    echo "InDesign cache directories not found, nothing to do"
fi
# Open the app again
echo "Opening InDesign..."
runAsUser open -a "$appPath"
sleep 5
# re-populate the variable
idProc=$(pgrep InDesign)
if [[ "$idProc" != "" ]]; then
    echo "InDesign opened"
else
    echo "Failed to automatically open InDesign"
fi
exit 0