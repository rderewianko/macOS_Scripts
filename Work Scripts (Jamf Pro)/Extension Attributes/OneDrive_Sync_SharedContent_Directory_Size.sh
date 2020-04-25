#!/bin/bash

########################################################################
#     OneDrive - Shared Content/SharePoint Online Directory Size       #
#################### written by Phil Walker Apr 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                            Functions                                 #
########################################################################

function sharedContentSyncDir ()
{
#Return the OneDrive shared content/SharePoint Online sync directory path

#Previous and current path.
oldFolderPath="/Users/${loggedInUser}/Bauer Group"
newFolderPath="/Users/${loggedInUser}/Bauer Media Group"

if [[ -d "$oldFolderPath" ]] && [[ ! -d "$newFolderPath" ]]; then
    sharedContentSyncPath="$oldFolderPath"
elif [[ ! -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    sharedContentSyncPath="$newFolderPath"
elif [[ -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    sharedContentSyncPath="$newFolderPath"
else
    sharedContentSyncPath=""
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
    sharedContentSyncDir
    if [[ "$sharedContentSyncPath" != "" ]]; then
        # Get the OneDrive shared content/SharePoint Online sync directory size for the logged in user
        FolderSize=$(du -hc "$sharedContentSyncPath" | grep "total" | awk '{ print $1 }')
	    echo "<result>$FolderSize</result>"
    else
        echo "<result>No shared content synced</result>"
	fi
fi

exit 0
