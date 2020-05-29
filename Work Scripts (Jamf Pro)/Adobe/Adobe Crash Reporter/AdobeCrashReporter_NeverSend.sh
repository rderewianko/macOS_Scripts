#!/bin/bash

########################################################################
#     Set Adobe Crash Reporter Send Settings to Always Never Send      #
#################### Written by Phil Walker May 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Adobe Crash Reporter current setting
crashReporterStatus=$(sudo -u "$loggedInUser" defaults read com.adobe.crashreporter always_never_send 2>/dev/null)

########################################################################
#                            Functions                                 #
########################################################################

function checkFilePerms ()
{
# Some users seem to have root set as the owner of the crash reporter preference domain
# Check the file exists first
crashReporterPlist="/Users/$loggedInUser/Library/Preferences/com.adobe.crashreporter.plist"
if [[ -f "$crashReporterPlist" ]]; then
    # Check ownership
    fileOwner=$(stat -f %Su /Users/$loggedInUser/Library/Preferences/com.adobe.crashreporter.plist 2>/dev/null)
    if [[ "$fileOwner" != "$loggedInUser" ]]; then
        # Set the file ownership to the logged in user
        chown "$loggedInUser" /Users/$loggedInUser/Library/Preferences/com.adobe.crashreporter.plist
        # re-populate variable to check changes have been made
        fileOwner=$(stat -f %Su /Users/$loggedInUser/Library/Preferences/com.adobe.crashreporter.plist 2>/dev/null)
        if [[ "$fileOwner" == "$loggedInUser" ]]; then
            echo "Corrected incorrect file permissions for preference domain com.adobe.crashreporter"
        else
            echo "Failed to correct file ownership, owner still $fileOwner"
        fi
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, exiting..."
else
    checkFilePerms
    if [[ "$crashReporterStatus" != "2" ]]; then
        echo "Setting Adobe Crash Reporter send settings for ${loggedInUser}"
        sudo -u "$loggedInUser" defaults write com.adobe.crashreporter always_never_send -int 2
        # re-populate variable
        crashReporterStatus=$(sudo -u "$loggedInUser" defaults read com.adobe.crashreporter always_never_send)
        if [[ "$crashReporterStatus" == "2" ]]; then
            echo "Adobe Crash Reporter send settings now set to Always Never Send for ${loggedInUser}"
        else
            echo "Failed to change Adobe Crash Reporter send settings for ${loggedInUser}"
            exit 1
        fi
    else
        echo "Adobe Crash Reporter send settings already correct for ${loggedInUser}"
    fi
fi

exit 0