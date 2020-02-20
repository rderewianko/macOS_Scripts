#!/bin/bash

########################################################################
#      Uninstall Microsoft Skype for Business and all preferences      #
################### Written by Phil Walker Feb 2020 ####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

# Check if Skype for Business is installed

if [[ -d /Applications/Skype\ for\ Business.app ]]; then

		rm -rf "/Applications/Skype\ for\ Business.app"

    echo "Skype for Business app removed"

else

		echo "Skype for Business app app not found"

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

    user_uid=$(echo "$the_user" | awk '{print $1}')
    user_gid=$(echo "$the_user" | awk '{print $2}')
    user_home=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}')

# Remove users' Library files

    if [[ -n "$user_home" ]]; then

    if [[ -d $user_home/Library/Containers/ ]]; then

		rm -rf /$user_home/Library/Containers/com.microsoft.errorreporting
		rm -rf /$user_home/Library/Containers/com.microsoft.SkypeForBusiness

		rm -rf /$user_home/Library/Caches/com.microsoft*

		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.SkypeForBusiness

		rm -f /$user_home/Library/Preferences/com.microsoft.SkypeForBusiness.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist

		echo "Users' Library Cleaned"

else

		echo "No Users' Library files found"

	fi

fi

done

# Remove System Library files

			rm -rf /Library/Application\ Support/Microsoft/MAU2.0
   		rm -rf /Library/Fonts/Microsoft
			rm -f /Library/LaunchAgents/com.microsoft.update.agent.plist
    	rm -f /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist
    	rm -f /Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist
			rm -f /Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist
    	rm -f /Library/Preferences/com.microsoft.Excel.plist
    	rm -f /Library/Preferences/com.microsoft.office.plist
    	rm -f /Library/Preferences/com.microsoft.office.setupassistant.plist
    	rm -f /Library/Preferences/com.microsoft.outlook.databasedaemon.plist
    	rm -f /Library/Preferences/com.microsoft.outlook.office_reminders.plist
    	rm -f /Library/Preferences/com.microsoft.Outlook.plist
    	rm -f /Library/Preferences/com.microsoft.PowerPoint.plist
    	rm -f /Library/Preferences/com.microsoft.Word.plist
    	rm -f /Library/Preferences/com.microsoft.office.licensingV2.plist
    	rm -f /Library/Preferences/com.microsoft.autoupdate2.plist
    	rm -rf /Library/Preferences/ByHost/com.microsoft
    	rm -rf /Library/Receipts/Office2016_*
			rm -rf /Library/Receipts/Office2019_*
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper

    	echo "System folders Cleaned"

    	echo "Removing Office 2016/2019 package receipts"

			pkgutil --forget com.microsoft.SkypeForBusiness
			pkgutil --forget microsoftskypeforbusinesssetdefaulttelephony

    	echo "All done! Microsoft Skype for Business has been removed"

exit 0
