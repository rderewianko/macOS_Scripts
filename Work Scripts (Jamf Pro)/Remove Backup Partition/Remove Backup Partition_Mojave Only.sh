#!/bin/bash

########################################################################
########################################################################
############################# Variables ################################
########################################################################
########################################################################

LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
Backup=$(diskutil list | grep -i "backup" | head -n1)
BackupID=$(diskutil list | grep -i "backup" | awk '{print $6}' | head -n1)
CoreStorage=$(diskutil list | grep -i "corestorage")
BackupIDCS=$(diskutil list | grep -i "apple_corestorage backup" | awk '{print $6}')
ContainerID=$(diskutil list | grep -i "apple_apfs container" | awk '{print $7}')
UUID=$(diskutil info /dev/"${BackupIDCS}" | grep -i "lvg uuid" | awk '{print $3}')
BackupType=$(diskutil info /dev/"${BackupID}" | grep -i "internal" | awk '{print $3}')
OneDriveFoldername=$(find /Users/$LoggedInUser -name \*OneDrive\* -type d -maxdepth 1 -print | sed 's/.*-//;s/ //')
OneDriveFolderSize=$(du -ks "/Users/$LoggedInUser/OneDrive - $OneDriveFoldername" | awk '{print $1}')
SIZE="1000"
user365="-1073741818"
userOnPRem="1073741824"
TMFinderMenu=$(defaults read /Users/$LoggedInUser/Library/Preferences/com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine")
SysUIPath="/Users/$LoggedInUser/Library/Preferences/com.apple.systemuiserver.plist"

########################################################################
########################################################################
############################## Functions ###############################
########################################################################
########################################################################

# Check if mac is at login window
function checkloginstatus ()
{
	if [[ "${LoggedInUser}" == "" ]]; then
		echo "No user logged in"
exit 0
else
		echo "${LoggedInUser} is logged in"
fi
}

# Check if user has O365 account
function check365users ()
{
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$LoggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')
  	if [[ "${mailboxValue}" == "${userOnPRem}" ]]; then
    	echo "${LoggedInUser} has no O365 account"
exit 0
else
    	echo "${LoggedInUser} has O365 account"
fi
}

# Check if user has OneDrive folder
function checkonedrivefolder ()
{
	if [[ "${OneDriveFoldername}" == "" ]]; then
		echo "${LoggedInUser} does not have a OneDrive folder"
exit 0
else
		echo "${LoggedInUser} does have a OneDrive folder"
fi
}

# Check the size of the users OneDrive folder to see if there is reasonable data present
function checkonedrivefoldersize ()
{
	if [[ "${OneDriveFolderSize}" -lt "${SIZE}" ]]; then
		echo "${LoggedInUser}'s OneDrive folder is empty"
exit 0
else
	if [[ "${OneDriveFolderSize}" -gt "${SIZE}" ]]; then
		echo "${LoggedInUser}'s OneDrive folder is not empty"
	fi
fi
}

# Check if the backup partition is internal and HFS+
function checkbackupdisk ()
{
	if [[ "${BackupType}" != "Internal" || "${BackupType}" == "" ]]; then
		echo "Backup partition is not present or it's an external disk"
exit 0
else
	if [[ "${BackupType}" == "Internal" ]]; then
		echo "Backup disk is present, internal and HFS+"
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/ReportPanic.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "		Backup Partition Removal" -description "Backup partition is no longer required on your Mac.
You have access to 1TB of OneDrive online storage.
Please make sure you continue copying all your local data to your OneDrive folder.
The Backup partion will be automatically removed from your Mac and the volume will disappear from your desktop.

If you require further information, please contact IT Service Desk on 0345 058 4444." -timeout 30
	fi
fi
}

# Stom TM backup befor removing the partition and remove finder menu item
function stoptmbackup ()
{
	tmutil stopbackup
		echo "TM backup has been stopped"
	tmutil disable 2>/dev/null
		echo "TM backup has been disabled"
	if [[ "${TMFinderMenu}" == 1 ]]; then
	sudo -u $LoggedInUser defaults write /Users/"${LoggedInUser}"/Library/Preferences/com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool false
	plutil -convert xml1 "${SysUIPath}"
	sed -ie 's/<string>\/System\/Library\/CoreServices\/Menu Extras\/TimeMachine.menu<\/string>//g' "${SysUIPath}"
	echo "TM finder menu is turned OFF and menu item removed"
fi
}

# After all checkes been carried out, now remove the backup partition
function removebackup ()
{
# Check if the backup partition is not part of a logical volume and then remove
	if [[ "${CoreStorage}" == "" ]]; then
		echo "Core storage not found"
	diskutil eraseVolume "Free Space" %noformat% /dev/"${BackupID}"
	diskutil APFS resizeContainer /dev/"${ContainerID}" 0
else
# Check if the backup partition is part of a logical volume and then remove
	if [[ "${CoreStorage}" != "" || "${Backup}" == "" ]]; then
		echo "Core storage found"
	diskutil cs deleteLVG "${UUID}"
sleep 3
UntitledID=$(diskutil list | grep -i "Untitled" | awk '{print $6}')
	diskutil eraseVolume "Free Space" %noformat% /dev/"${UntitledID}"
	diskutil APFS resizeContainer /dev/"${ContainerID}" 0
		echo "Backup partition has been successfully removed"
else
		echo "Something has gone wrong! Backup partition could not be removed"
	fi
fi
}

########################################################################
########################################################################
############################## Script execution ########################
########################################################################
########################################################################

checkloginstatus
check365users
checkonedrivefolder
checkonedrivefoldersize
checkbackupdisk
stoptmbackup
removebackup

exit 0
