#!/bin/bash

########################################################################
#  Uninstall Microsoft Office 2016/2019/365 Suite and all preferences  #
################### Written by Phil Walker Feb 2020 ####################
########################################################################

########################################################################
#                            Functions                                 #
########################################################################

function removeMAU ()
{
# Only remove MAU if no other app is dependent on it for updates
mauApps=$(ls /Applications/ | grep -i "Microsoft" | grep -i "Edge\|Remote\|Defender\|Portal")

if [[ "$mauApps" != "" ]]; then

	echo "MAU required by other applications so will not be removed"

else

	echo "Removing MAU components..."

		rm -rf /Library/Application\ Support/Microsoft/MAU2.0 2>/dev/null
		rm -f /Library/LaunchAgents/com.microsoft.update.agent.plist 2>/dev/null
		rm -f /Library/Preferences/com.microsoft.autoupdate2.plist 2>/dev/null
		pkgutil --forget com.microsoft.package.Microsoft_AutoUpdate.app 2>/dev/null
		pkgutil --forget com.microsoft.package.Microsoft_AU_Bootstrapper.app 2>/dev/null

fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Check if Office 2016/2019 is installed

if [[ -d /Applications/Microsoft\ Word.app/ ]]; then

	echo "Removing Office applications..."

		rm -rf "/Applications/Microsoft Excel.app" 2>/dev/null
		rm -rf "/Applications/Microsoft OneNote.app" 2>/dev/null
  		rm -rf "/Applications/Microsoft Outlook.app" 2>/dev/null
  		rm -rf "/Applications/Microsoft PowerPoint.app" 2>/dev/null
  		rm -rf "/Applications/Microsoft Word.app" 2>/dev/null
		rm -rf "/Applications/OneDrive.app" 2>/dev/null
		rm -rf "/Applications/Microsoft Teams.app" 2>/dev/null

else

		echo "Office 2016/2019/365 apps not found"

fi

removeMAU

# Remove Office 2016 volume license file

if [ -e "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]; then

	rm -f /Library/Preferences/com.microsoft.office.licensingV2.plist 2>/dev/null

	echo "Office 2016 volume license file removed"

else

    echo "Office 2016 volume license file not found"

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

			echo "Cleaning all Microsoft Office preferences for ${user_name}"

# Only remove MAU preferences if no other app is dependent on it for updates
		mauApps=$(ls /Applications/ | grep -i "Microsoft" | grep -i "Edge\|Remote\|Defender\|Portal")

		if [[ "$mauApps" == "" ]]; then

			rm -f $user_home/Library/Preferences/com.microsoft.autoupdate.fba.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.autoupdate2.plist 2>/dev/null
			rm -rf $user_home/Library/Application\ Support/Microsoft\ AutoUpdate 2>/dev/null
			rm -rf $user_home/Library/Application\ Support/Microsoft\ AU\ Daemon 2>/dev/null

		fi

    if [[ -d $user_home/Library/Containers/ ]]; then

			rm -rf $user_home/Library/Containers/com.microsoft.errorreporting 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.Excel 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.openxml.excel.app 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.netlib.shipassertprocess 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.Office365ServiceV2 2>/dev/null
    		rm -rf $user_home/Library/Containers/com.microsoft.OneDrive.FinderSync 2>/dev/null
			rm -rf $user_home/Library/Containers/com.Microsoft.OsfWebHost 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.Outlook 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.Powerpoint 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.RMS-XPCService 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.SkypeForBusiness 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.Word 2>/dev/null
			rm -rf $user_home/Library/Containers/com.microsoft.onenote.mac 2>/dev/null

			rm -rf $user_home/Library/Cookies/com.microsoft.onedrive.binarycookies 2>/dev/null
			rm -rf $user_home/Library/Cookies/com.microsoft.onedriveupdater.binarycookies 2>/dev/null

			rm -rf $user_home/Library/Caches/Microsoft2>/dev/null
			rm -rf $user_home/Library/Caches/OneDrive 2>/dev/null
			rm -rf $user_home/Library/Caches/com.microsoft* 2>/dev/null

			rm -rf $user_home/Library/Application\ Scripts/com.Microsoft.OsfWebHost 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.Powerpoint 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.SkypeForBusiness 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.Word 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.OneDrive.FinderSync 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.onenote.mac 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.Office365ServiceV2 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.Excel 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.openxml.excel.app 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.errorreporting 2>/dev/null
			rm -rf $user_home/Library/Application\ Scripts/com.microsoft.Outlook 2>/dev/null

			rm -f $user_home/Library/Preferences/com.microsoft.onenote.mac.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.Outlook.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.OneDrive.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.SkypeForBusiness.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.Excel.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.office.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.Powerpoint.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.Word.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist 2>/dev/null
			rm -f $user_home/Library/Preferences/com.microsoft.OneDriveUpdater.plist 2>/dev/null
			rm -rf $user_home/Library/Preferences/ByHost/com.microsoft* 2>/dev/null

			rm -rf $user_home/Library/WebKit/com.microsoft* 2>/dev/null

			rm -rf $user_home/Library/Application\ Support/com.microsoft.OneDriveUpdater 2>/dev/null
			rm -rf $user_home/Library/Application\ Support/com.microsoft.OneDrive 2>/dev/null
			rm -rf $user_home/Library/Application\ Support/OneDrive 2>/dev/null
			rm -rf $user_home/Library/Application\ Support/OneDriveUpdater 2>/dev/null

	fi

	if [[ -d $user_home/Library/Group\ Containers/ ]]; then

      	rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.ms 2>/dev/null
    	rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.Office 2>/dev/null
		rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.OfficeOneDriveSyncIntegration 2>/dev/null
    	rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.OfficeOsfWebHost 2>/dev/null
		rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.OneDriveStandaloneSuite 2>/dev/null
		rm -rf $user_home/Library/Group\ Containers/UBF8T346G9.OneDriveSyncClientSuite 2>/dev/null

	fi

	echo "Microsoft Office preferences cleaned successfully for ${user_name}"

fi

done

# Remove System Library files

		rm -rf /Library/Fonts/Microsoft 2>/dev/null
    	rm -f /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist 2>/dev/null
    	rm -f /Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist 2>/dev/null
		rm -f /Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.Excel.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.office.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.office.setupassistant.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.outlook.databasedaemon.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.outlook.office_reminders.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.Outlook.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.PowerPoint.plist 2>/dev/null
    	rm -f /Library/Preferences/com.microsoft.Word.plist 2>/dev/null
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper 2>/dev/null
    	rm -f /Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper 2>/dev/null

    		echo "Microsoft Office System preferences cleaned"

    		echo "Removing Office 2016/2019/365 package receipts..."

			pkgutil --forget com.microsoft.package.Fonts 2>/dev/null
			pkgutil --forget com.microsoft.package.DFonts 2>/dev/null
			pkgutil --forget com.microsoft.pkg.licensing.volume 2>/dev/null
			pkgutil --forget com.microsoft.pkg.licensing 2>/dev/null
			pkgutil --forget com.microsoft.package.Microsoft_Excel.app 2>/dev/null
			pkgutil --forget com.microsoft.package.Microsoft_OneNote.app 2>/dev/null
			pkgutil --forget com.microsoft.package.Microsoft_Outlook.app 2>/dev/null
			pkgutil --forget com.microsoft.package.Microsoft_PowerPoint.app 2>/dev/null
			pkgutil --forget com.microsoft.package.Microsoft_Word.app 2>/dev/null
			pkgutil --forget com.microsoft.OneDrive 2>/dev/null
			pkgutil --forget com.microsoft.SkypeForBusiness 2>/dev/null
			pkgutil --forget com.microsoft.package.Proofing_Tools 2>/dev/null
			pkgutil --forget com.microsoft.package.licensing 2>/dev/null
			pkgutil --forget com.microsoft.pkg.licensing 2>/dev/null
			pkgutil --forget com.microsoft.package.Frameworks 2>/dev/null
			pkgutil --forget com.microsoft.teams 2>/dev/null
			pkgutil --forget microsoftskypeforbusinesssetdefaulttelephony 2>/dev/null

      	echo "All done! Microsoft Office has been removed"

exit 0
