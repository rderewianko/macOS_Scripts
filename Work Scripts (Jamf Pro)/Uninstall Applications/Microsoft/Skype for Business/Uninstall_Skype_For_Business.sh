#!/bin/bash

########################################################################
#      Uninstall Microsoft Skype for Business and all preferences      #
################### Written by Phil Walker Feb 2020 ####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

# Check if Skype for Business is installed

if [[ -d "/Applications/Skype for Business.app" ]]; then

	echo "Removing Skype for Business application..."

	rm -rf "/Applications/Skype for Business.app"

else

	echo "Skype for Business application app not found"

fi

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

cat "$tmp_users" | while read the_user; do

    user_home=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}')
		user_name=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}' | cut -c8-)

# Remove users' Library files

    if [[ -n "$user_home" ]]; then

			echo "Cleaning all Skype for Business preferences for ${user_name}"

    		if [[ -d $user_home/Library/Containers/ ]]; then

					rm -rf $user_home/Library/Containers/com.microsoft.SkypeForBusiness

					rm -rf $user_home/Library/Caches/com.microsoft*

					rm -rf $user_home/Library/Application\ Scripts/com.microsoft.SkypeForBusiness

					rm -f $user_home/Library/Preferences/com.microsoft.SkypeForBusiness.plist
					rm -f $user_home/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist

					echo "Skype for Business preferences cleaned successfully for ${user_name}"

else

		echo "Skype for Business preferences found for ${user_name}"

	fi

fi

done

# Remove System Library files

			rm -f /Library/LaunchAgents/com.bauer.OpenSkypeForBusinessAfterUserLogin.plist
			rm -f /Library/StartupItems/OpenSkypeForBusinessAfterUserLogin.sh

    	echo "Skype for Business System preferences cleaned"

    	echo "Removing Skype for Business package receipts..."

			pkgutil --forget com.microsoft.SkypeForBusiness
			pkgutil --forget microsoftskypeforbusinesssetdefaulttelephony

    	echo "All done! Microsoft Skype for Business has been removed"

exit 0
