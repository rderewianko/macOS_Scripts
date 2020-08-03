#!/bin/bash

########################################################################
#          Uninstall Roxio Toast Titanium (version 9 and 10)           #
################## Written by Phil Walker Aug 2020 #####################
########################################################################
# Legacy 32-bit applications

########################################################################
#                            Variables                                 #
########################################################################

# Toast 9 Titanium app
toastNine="/Applications/Toast 9 Titanium"
# Toast 10 Titanium app
toastTen="/Applications/Toast 10 Titanium"
# Toast Preference directory
toastPreferences="/Library/Application Support/Roxio"

########################################################################
#                            Functions                                 #
########################################################################

function closeToast ()
{
# Toast Titanium process ID
toastPID=$(pgrep "Toast")
if [[ "$toastPID" != "" ]]; then
    echo "Killing Toast Titanium process..."
    while [[ "$toastPID" != "" ]]; do
        for proc in $toastPID; do
            kill -9 "$proc" 2>/dev/null
        done
    sleep 2
    # re-populate variable
    toastPID=$(pgrep "Toast")
    done
    echo "Toast Titanium process killed"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# If found, kill the Toast process
closeToast

# If found, uninstall Toast 9 Titanium
if [[ -d "$toastNine" ]]; then
    echo "Toast 9 Titanium found"
    rm -rf "$toastNine"
    sleep 2
    if [[ ! -d "$toastNine" ]]; then
        echo "Toast 9 Titanium application uninstalled successfully"
    else
        echo "Failed to uninstall Toast 9 Titanium application!"
        exit 1
    fi
fi

# If found, uninstall Toast 10 Titanium
if [[ -d "$toastTen" ]]; then
    echo "Toast 10 Titanium found"
    rm -rf "$toastTen"
    sleep 2
    if [[ ! -d "$toastTen" ]]; then
        echo "Toast 10 Titanium application uninstalled successfully"
    else
        echo "Failed to uninstall Toast 10 Titanium application!"
        exit 1
    fi
fi

# Remove Toast preferences
if [[ -d "$toastPreferences" ]]; then
    echo "Toast Titanium preferences found"
    rm -rf "$toastPreferences"
    if [[ ! -d "$toastPreferences" ]]; then
        echo "Toast Titanium preferences deleted"
    else
        echo "Failed to clean-up Toast preferences!"
        exit 1
    fi
else
    echo "Toast preferences not found"
fi

# Remove all Toast Titanium user preferences
tmp_users=$(mktemp "/tmp/users-unsort-XXXXX") # Make some temp files to hold the user lists
if [[ -z "$tmp_users" ]]; then
	echo "error: could not make tmp file"
	exit 1
fi
# Make a list of homes that are in /Users
for the_folder in "$targetVolume/Users"; do
	if [[ -d "$the_folder" ]]; then
  		ls -lTn "$the_folder" | awk -v vDIR="$the_folder" '/^d/{vUID = $3; vGID = $4; sub("^.*[0-9]+:[0-9]+.[0-9]+","");sub("^ +","");if($0 !~ "^[.]"){print vUID, vGID, vDIR "/" $0}}'
	fi
done | sed '/\/Shared/d' >> "$tmp_users"
# Walk the list of user details, get the users UID, GID and home folder path
cat "$tmp_users" | while read -r the_user; do
	user_home=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}')
	user_name=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}' | cut -c8-)
	# Remove users' Library files
    if [[ -n "$user_home" ]]; then
        echo "Cleaning all Roxio Toast Titanium preferences for ${user_name}"
        # Contains a 32-bit app called Roxio Restore
        rm -rf "${user_home}/Library/Application Support/Roxio" 2>/dev/null
        # 32-bit component ToastIt.service
        rm -rf "${user_home}/Library/Services/ToastIt.service" 2>/dev/null
        # Other prefs - Directories
        rm -rf "${user_home}/Library/Application Support/Roxio" 2>/dev/null
        rm -rf "${user_home}/Library/Library/Caches/com.roxio.Toast" 2>/dev/null
        rm -rf "${user_home}/Documents/Roxio Converted Items" 2>/dev/null
        rm -rf "${user_home}/Library/Preferences/Roxio Toast Prefs" 2>/dev/null
        # Other prefs - Files
        rm -f "${user_home}/Library/Preferences/com.roxio.Toast.LSSharedFileList.plist" 2>/dev/null
        rm -f "${user_home}/Library/Preferences/com.roxio.Toast.plist" 2>/dev/null
        rm -f "${user_home}/Library/Preferences/com.roxio.videoplayer.plist" 2>/dev/null
        rm -f "${user_home}/Library/Preferences/com.elgato.VideoPlayer.plist" 2>/dev/null
        if [[ ! -d "${user_home}/Library/Application Support/Roxio" ]] && [[ ! -d "${user_home}/Library/Services/ToastIt.service" ]]; then
            echo "Roxio Toast Titanium preferences cleaned successfully for ${user_name}"
        else
            echo "32-bit apps and components still installed, process failed!"
            exit 1
        fi
    fi
done

exit 0

