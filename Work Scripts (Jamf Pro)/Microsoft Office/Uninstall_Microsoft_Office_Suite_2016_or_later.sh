#!/bin/bash

########################################################################
#  Uninstall Microsoft Office 2016/2019/365 Suite and all preferences  #
#################### Written by Phil Walker August #####################
########################################################################

########################################################################
#                             Functions                                #
########################################################################

function removeMAU ()
{
#Only remove MAU if no other app is dependent on it for updates
mauApps=$(ls /Applications/ | grep -i "Microsoft" | grep -i "Edge\|Remote\|Defender\|Portal")
if [[ "$mauApps" != "" ]]; then
	echo "Microsoft Auto Update required by other applications so will not be removed"
else
	echo "Removing Microsoft Auto Update..."
	rm -rf /Library/Application\ Support/Microsoft/MAU2.0
	rm -f /Library/LaunchAgents/com.microsoft.update.agent.plist
	rm -f /Library/Preferences/com.microsoft.autoupdate2.plist
	pkgutil --forget com.microsoft.package.Microsoft_AutoUpdate.app
	pkgutil --forget com.microsoft.package.Microsoft_AU_Bootstrapper.app
fi
}

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
		rm -rf "/Applications/Microsoft Teams.app"

    	echo "Office 2016/2019/365 apps removed"

else

		echo "Office 2016/2019/365 apps not found"

fi

# Remove Office 2016 volume license file

	if [ -e "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]; then

	rm -f /Library/Preferences/com.microsoft.office.licensingV2.plist

    	echo "Office 2016 volume license file removed"

else

    	echo "Office 2016 volume license file not found"

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

		rm -f /$user_home/Library/Preferences/com.microsoft.autoupdate.fba.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.onenote.mac.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.Outlook.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.autoupdate2.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.OneDrive.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.SkypeForBusiness.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.Excel.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.office.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.Powerpoint.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.Word.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist
		rm -f /$user_home/Library/Preferences/com.microsoft.OneDriveUpdater.plist
		rm -rf /$user_home/Library/Preferences/ByHost/com.microsoft*

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
			rm -rf /$user_home/Library/Group\ Containers/UBF8T346G9.OneDriveSyncClientSuite


        echo "Group Container Cleaned"

else

		echo "No Group Container files found"

fi

done

# Remove System Library files

			rm -rf /Library/Fonts/Microsoft
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
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper

    	echo "System folders Cleaned"

    	echo "Removing Office 2016/2019 package receipts"

			pkgutil --forget com.microsoft.package.Fonts
			pkgutil --forget com.microsoft.package.DFonts
			pkgutil --forget com.microsoft.pkg.licensing.volume >/dev/null 2>&1
			pkgutil --forget com.microsoft.pkg.licensing >/dev/null 2>&1
			pkgutil --forget com.microsoft.package.Microsoft_Excel.app
			pkgutil --forget com.microsoft.package.Microsoft_OneNote.app
			pkgutil --forget com.microsoft.package.Microsoft_Outlook.app
			pkgutil --forget com.microsoft.package.Microsoft_PowerPoint.app
			pkgutil --forget com.microsoft.package.Microsoft_Word.app
			pkgutil --forget com.microsoft.OneDrive
			pkgutil --forget com.microsoft.SkypeForBusiness
			pkgutil --forget com.microsoft.package.Proofing_Tools
			pkgutil --forget com.microsoft.package.licensing
			pkgutil --forget com.microsoft.pkg.licensing
			pkgutil --forget com.microsoft.package.Frameworks
			pkgutil --forget com.microsoft.teams
			pkgutil --forget microsoftskypeforbusinesssetdefaulttelephony

      echo "All done!"

exit 0
