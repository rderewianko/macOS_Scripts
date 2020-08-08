#!/bin/bash

########################################################################
#                    Uninstall Transmit 4 (Panic)                      #
################## Written by Phil Walker Aug 2020 #####################
########################################################################
# Legacy application that is not supported on anything later than Sierra (10.12)

########################################################################
#                            Variables                                 #
########################################################################

# Transmit app
transmitApp="/Applications/Transmit.app"
# Transmit Version
transmitVer=$(defaults read /Applications/Transmit.app/Contents/Info.plist CFBundleShortVersionString | cut -c-1 2>/dev/null)

########################################################################
#                            Functions                                 #
########################################################################

function closeTransmit ()
{
# Transmit process ID
transmitPID=$(pgrep "Transmit")
if [[ "$transmitPID" != "" ]]; then
    echo "Killing Transmit process..."
    while [[ "$transmitPID" != "" ]]; do
        for proc in $transmitPID; do
            kill -9 "$proc" 2>/dev/null
        done
    sleep 2
    # re-populate variable
    transmitPID=$(pgrep "Transmit")
    done
    echo "Transmit process killed"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Uninstall Transmit 4
if [[ -d "$transmitApp" ]]; then
    if [[ "$transmitVer" -eq "4" ]]; then
        echo "Transmit version 4 found"
        # If found, kill the Transmit process
        closeTransmit
        # Remove the app
        rm -rf "$transmitApp"
        sleep 2
        if [[ ! -d "$transmitApp" ]]; then
            echo "Transmit 4 application uninstalled successfully"
        else
            echo "Failed to uninstall Toast 9 Titanium application!"
            exit 1
        fi
    fi
fi

# Remove TransmitSync app (32-bit app)
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
    if [[ -n "$user_home" ]]; then
        if [[ -d "${user_home}/Library/Application Support/Transmit/TransmitSync.app" ]]; then
            echo "Removing the 32-bit user app TransmitSync for ${user_name}"
            # 32-bit app Transmit Sync
            rm -rf "${user_home}/Library/Application Support/Transmit/TransmitSync.app" 2>/dev/null
            if [[ ! -d "${user_home}/Library/Application Support/Transmit/TransmitSync.app" ]]; then
                echo "Successfully removed TransmitSync for ${user_name}"
            else
                echo "Failed to remove TransmitSync for ${user_name}!"
            fi
        fi
    fi
done

exit 0