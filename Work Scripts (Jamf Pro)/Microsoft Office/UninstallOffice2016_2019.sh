#!/bin/bash

########################################################################
#       Uninstall Microsoft Office 2016/2019 and all preferences       #
#################### Written by Phil Walker August #####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

# Check if Office 2016/2019 is installed

	if [[ -d /Applications/Microsoft\ Word.app/ ]]; then

		rm -rf "/Applications/Microsoft Excel.app"
		rm -rf "/Applications/Microsoft OneNote.app"
    	rm -rf "/Applications/Microsoft Outlook.app"
    	rm -rf "/Applications/Microsoft PowerPoint.app"
    	rm -rf "/Applications/Microsoft Word.app"
			rm -rf "/Applications/OneDrive.app"
			rm -rf "/Applications/Skype\ for\ Business.app"

    	echo "Office 2016/2019 apps removed"

else

		echo "Office 2016/2019 apps not found"

fi

# Remove Office 2016 license file

	if [ -e "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]; then

	rm /Library/Preferences/com.microsoft.office.licensingV2.plist

    	echo "license file removed"

else

    	echo "license file not found"

fi

# Make some temp files to hold the user lists

tmp_users=`mktemp "/tmp/users-unsort-XXXXX"`

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

    user_uid=`echo "$the_user" | awk '{print $1}'`
    user_gid=`echo "$the_user" | awk '{print $2}'`
    user_home=`echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}'`

# Remove users' Library files

    if [[ -n "$user_home" ]]; then

    if [[ -d $user_home/Library/Containers/ ]]; then

		rm -rf /$user_home/Library/Containers/com.microsoft.errorreporting
		rm -rf /$user_home/Library/Containers/com.microsoft.Excel
		rm -rf /$user_home/Library/Containers/com.microsoft.openxml.excel.app
		rm -rf /$user_home/Library/Containers/com.microsoft.netlib.shipassertprocess
		rm -rf /$user_home/Library/Containers/com.microsoft.Office365ServiceV2
    rm -rf /$user_home/Library/Containers/com.microsoft.OneDrive.FinderSync
		rm -rf /$user_home/Library/Containers/com.Microsoft.OsfWebHost
		rm -rf /$user_home/Library/Containers/com.microsoft.Outlook
		rm -rf /$user_home/Library/Containers/com.microsoft.Powerpoint
		rm -rf /$user_home/Library/Containers/com.microsoft.RMS-XPCService
		rm -rf /$user_home/Library/Containers/com.microsoft.SkypeForBusiness
		rm -rf /$user_home/Library/Containers/com.microsoft.Word
		rm -rf /$user_home/Library/Containers/com.microsoft.onenote.mac

		rm -rf /$user_home/Library/Cookies/com.microsoft.onedrive.binarycookies
		rm -rf /$user_home/Library/Cookies/com.microsoft.onedriveupdater.binarycookies

		rm -rf /$user_home/Library/Caches/Microsoft
		rm -rf /$user_home/Library/Caches/OneDrive
		rm -rf /$user_home/Library/Caches/com.microsoft*

		rm -rf /$user_home/Library/Application\ Scripts/com.Microsoft.OsfWebHost
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.Powerpoint
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.SkypeForBusiness
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.Word
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.OneDrive.FinderSync
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.onenote.mac
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.Office365ServiceV2
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.Excel
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.openxml.excel.app
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.errorreporting
		rm -rf /$user_home/Library/Application\ Scripts/com.microsoft.Outlook

		rm /$user_home/Library/Preferences/com.microsoft.autoupdate.fba.plist
		rm /$user_home/Library/Preferences/com.microsoft.onenote.mac.plist
		rm /$user_home/Library/Preferences/com.microsoft.Outlook.plist
		rm /$user_home/Library/Preferences/com.microsoft.autoupdate2.plist
		rm /$user_home/Library/Preferences/com.microsoft.OneDrive.plist
		rm /$user_home/Library/Preferences/com.microsoft.SkypeForBusiness.plist
		rm /$user_home/Library/Preferences/com.microsoft.Excel.plist
		rm /$user_home/Library/Preferences/com.microsoft.office.plist
		rm /$user_home/Library/Preferences/com.microsoft.Powerpoint.plist
		rm /$user_home/Library/Preferences/com.microsoft.Word.plist
		rm /$user_home/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist
		rm /$user_home/Library/Preferences/com.microsoft.OneDriveUpdater.plist

		rm -rf /$user_home/Library/WebKit/com.microsoft.*

		rm -rf /$user_home/Library/Application\ Support/Microsoft\ AutoUpdate
		rm -rf /$user_home/Library/Application\ Support/com.microsoft.OneDriveUpdater
		rm -rf /$user_home/Library/Application\ Support/com.microsoft.OneDrive
		rm -rf /$user_home/Library/Application\ Support/OneDrive
		rm -rf /$user_home/Library/Application\ Support/OneDriveUpdater
		rm -rf /$user_home/Library/Application\ Support/Microsoft\ AU\ Daemon

		echo "Users' Library Cleaned"

else

		echo "No Users' Library files found"

	fi

fi

	if [[ -d $user_home/Library/Group\ Containers/ ]]; then

      rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.ms
    	rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.Office
			rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.OfficeOneDriveSyncIntegration
    	rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.OfficeOsfWebHost
			rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.OneDriveStandaloneSuite


        echo "Group Container Cleaned"

else

		echo "No Group Container files found"

fi

done

# Remove System Library files

		rm -rf /Library/Application\ Support/Microsoft/MAU2.0
   		rm -rf /Library/Fonts/Microsoft
			rm /Library/LaunchAgents/com.microsoft.update.agent.plist
    	rm /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist
    	rm /Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist
			rm /Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist
    	rm /Library/Preferences/com.microsoft.Excel.plist
    	rm /Library/Preferences/com.microsoft.office.plist
    	rm /Library/Preferences/com.microsoft.office.setupassistant.plist
    	rm /Library/Preferences/com.microsoft.outlook.databasedaemon.plist
    	rm /Library/Preferences/com.microsoft.outlook.office_reminders.plist
    	rm /Library/Preferences/com.microsoft.Outlook.plist
    	rm /Library/Preferences/com.microsoft.PowerPoint.plist
    	rm /Library/Preferences/com.microsoft.Word.plist
    	rm /Library/Preferences/com.microsoft.office.licensingV2.plist
    	rm /Library/Preferences/com.microsoft.autoupdate2.plist
    	rm -rf /Library/Preferences/ByHost/com.microsoft
    	rm -rf /Library/Receipts/Office2016_*
			rm -rf /Library/Receipts/Office2019_*
    	rm /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper
    	rm /Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper

    	echo "System folders Cleaned"

    	echo "Making the Mac forget about Office 2016/2019"

		pkgutil --forget com.microsoft.package.Fonts
		pkgutil --forget com.microsoft.package.Microsoft_AutoUpdate.app
		pkgutil --forget com.microsoft.package.Microsoft_Excel.app
		pkgutil --forget com.microsoft.package.Microsoft_OneNote.app
		pkgutil --forget com.microsoft.package.Microsoft_Outlook.app
		pkgutil --forget com.microsoft.package.Microsoft_PowerPoint.app
		pkgutil --forget com.microsoft.package.Microsoft_Word.app
		pkgutil --forget com.microsoft.package.Proofing_Tools
		pkgutil --forget com.microsoft.package.licensing

        echo "All done! Microsoft Silverlight might need reinstalling"

exit 0
