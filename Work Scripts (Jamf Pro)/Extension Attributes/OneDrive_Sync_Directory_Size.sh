#!/bin/bash

########################################################################
#                  OneDrive - User Data Directory Size                 #
################ written by Suleyman Twana & Phil Walker ###############
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                            Functions                                 #
########################################################################

function oneDriveSyncDir ()
{
#Return the OneDrive sync directory path

#Previous and current path.
oldFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Group"
newFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Media Group"

if [[ -d "$oldFolderPath" ]] && [[ ! -d "$newFolderPath" ]]; then
    OneDrivePath="$oldFolderPath"
elif [[ ! -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    OneDrivePath="$newFolderPath"
elif [[ -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    OneDrivePath="$newFolderPath"
else
    OneDrivePath=""
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

# Only check if a user is logged in
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "<result>No logged in user</result>"
    exit 0
else
    oneDriveSyncDir
    if [[ "$OneDrivePath" != "" ]]; then
        # Get OneDrive directory size for the logged in user
        FolderSize=$(du -hc "$OneDrivePath" | grep "total" | awk '{ print $1 }')
	    echo "<result>$FolderSize</result>"
    else
        echo "<result>OneDrive not configured</result>"
	fi
fi

exit 0