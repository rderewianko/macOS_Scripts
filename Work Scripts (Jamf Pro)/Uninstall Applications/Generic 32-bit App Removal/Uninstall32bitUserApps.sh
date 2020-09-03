#!/bin/bash

########################################################################
#       Uninstall Old 32-bit Applications Found in User Profiles       #
################## Written by Phil Walker Aug 2020 #####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

# Make some temp files to hold the user lists
tmp_users=$(mktemp "/tmp/users-unsort-XXXXX")
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
        echo "Checking for legacy 32-bit applications in ${user_name}'s profile..."
        if [[ -d "${user_home}/Library/Application Support/Transmit/TransmitSync.app" ]]; then
            # 32-bit app Transmit Sync
            rm -rf "${user_home}/Library/Application Support/Transmit/TransmitSync.app" 2>/dev/null
            if [[ ! -d "${user_home}/Library/Application Support/Transmit/TransmitSync.app" ]]; then
                echo "Removed TransmitSync successfully for ${user_name}"
            fi
        fi
        if [[ -d "${user_home}/Library/Application Support/RealNetworks/RealPlayer Downloader Agent.app" ]]; then
            # 32-bit app RealPlayer Downloader Agent
            rm -rf "${user_home}/Library/Application Support/RealNetworks/RealPlayer Downloader Agent.app" 2>/dev/null
            if [[ ! -d "${user_home}/Library/Application Support/RealNetworks/RealPlayer Downloader Agent.app" ]]; then
                echo "Removed RealPlayer Downloader Agent successfully for ${user_name}"
            fi
        fi
        if [[ -d "${user_home}/Library/Application Support/Roxio/Roxio Restore.app" ]]; then
            # 32-bit app for Roxio Toast Titanium v9/v10
            rm -rf "${user_home}/Library/Application Support/Roxio/Roxio Restore.app"
            if [[ ! -d "${user_home}/Library/Application Support/Roxio/Roxio Restore.app" ]]; then
                echo "Removed Roxio Restore successfully for ${user_name}"
            fi
        fi
        if [[ -d "${user_home}/Library/Application Support/CitrixOnline/CitrixOnlineLauncher.app" ]]; then
            # 32-bit app Citrix Online Launcher - Replaced with Citrix Workspace app in August 2018.
            rm -rf "${user_home}/Library/Application Support/CitrixOnline/CitrixOnlineLauncher.app" 2>/dev/null
            if [[ ! -d "${user_home}/Library/Application Support/CitrixOnline/CitrixOnlineLauncher.app" ]]; then
                echo "Removed Citrix Online Launcher successfully for ${user_name}"
            fi
        fi
        # Android File Transfer used to be a 32-bit application so remove it anyway. It'll be re-created on the next launch of Android File Transfer
        if [[ -d "${user_home}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent.app" ]]; then
            agentPID=$(pgrep "Android File Transfer Agent")
            if [[ "$agentPID" != "" ]]; then
                kill -9 "$agentPID"
                sleep 2
            fi
            rm -rf "${user_home}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent.app" 2>/dev/null
        fi
        # Legacy versions of GoToMeeting
        if [[ -d "${user_home}/Applications/GoToMeeting" ]] || [[ -d "${user_home}/Applications/GoToMeeting.app" ]]; then
            rm -rf "${user_home}/Applications/GoToMeeting*.app" 2>/dev/null
            rm -rf "${user_home}/Applications/GoToMeeting"
        fi
        echo "-------------------------------------------------------------------------"
    fi
done

exit 0