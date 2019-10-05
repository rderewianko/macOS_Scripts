#!/bin/bash

########################################################################
#                Remove Backup partition macOS Sierra                  #
##################### Written by Suleyman Twana ########################
##################### Modified by Phil Walker Sept 2019 ################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
macintoshHDID=$(diskutil list | grep -i "macintosh hd" | awk '{print $7}' | head -n1)
backupPartition=$(diskutil list | grep -i "backup" | head -n1)
backupID=$(diskutil list | grep -i "backup" | awk '{print $6}' | head -n1)
backupType=$(diskutil info /dev/"${backupID}" | grep -i "internal" | awk '{print $3}')
coreStorage=$(diskutil list | grep -i "corestorage")
backupIDCS=$(diskutil list | grep -i "apple_corestorage backup" | awk '{print $6}')
backupUUID=$(diskutil info /dev/"${backupIDCS}" | grep -i "lvg uuid" | awk '{print $3}')
user365="-1073741818"
userOnPrem="1073741824"
tmFinderMenu=$(defaults read /Users/$loggedInUser/Library/Preferences/com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" 2>/dev/null)
sysUIPath="/Users/$loggedInUser/Library/Preferences/com.apple.systemuiserver.plist"
#OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')

########################################################################
#                            Functions                                 #
########################################################################

#Check if the Mac is at the login window
function checkLoginStatus ()
{
if [[ "${loggedInUser}" == "" ]]; then
	echo "No user logged in, exiting..."
	exit 0
else
	echo "${loggedInUser} is logged in"
fi
}

#Check if the user has an O365 account
function check365Users ()
{
#Check we can get to AD
domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
if [[ "$domainPing" == "" ]]; then
	echo "Domain not reachable, exiting..."
	exit 0
fi
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print $2}')
if [[ "${mailboxValue}" == "${userOnPrem}" ]]; then
	echo "${loggedInUser} is an On-Premises user, exiting..."
	exit 0
else
  echo "${loggedInUser} is an Office 365 user"
fi
}

# Check if the backup partition is internal and HFS+
function checkBackupDisk ()
{
if [[ "${backupType}" != "Internal" || "${backupType}" == "" ]]; then
	echo "Backup partition is not present or it's an external disk, exiting..."
	exit 0
else
	if [[ "${backupType}" == "Internal" ]]; then
		echo "Backup disk is present, internal and HFS+"
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/ReportPanic.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "		Backup Partition Removal" -description "The Backup partition is no longer required on your Mac.
You have access to 1TB of OneDrive online storage.
Please make sure you continue copying all of your local data to your OneDrive folder.
The Backup partion will be automatically removed from your Mac and the volume will disappear from your desktop.

If you require further information, please contact IT Service Desk on 0345 058 4444." -timeout 30
	fi
fi
}

# Stop TM backup befor removing the partition and remove finder menu item
function stopTMBackup ()
{
tmutil stopbackup
	echo "TM backup has been stopped"
tmutil disable 2>/dev/null
	echo "TM backup has been disabled"
if [[ "${tmFinderMenu}" == 1 ]]; then
	sudo -u $loggedInUser defaults write /Users/"${loggedInUser}"/Library/Preferences/com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool FALSE
	plutil -convert xml1 "${sysUIPath}"
	sed -ie 's/<string>\/System\/Library\/CoreServices\/Menu Extras\/TimeMachine.menu<\/string>//g' "${sysUIPath}"
	killall SystemUIServer
	echo "TM removed from the menu bar"
fi
}

# After all checkes been carried out, now remove the backup partition
function removeBackup ()
{
# Check if the backup partition is not part of a logical volume and then remove
	if [[ "${coreStorage}" == "" ]] && [[ "$backupPartition" != "" ]]; then
		echo "Backup partition found and CoreStorage not found"
		echo "Removing Backup partition..."
		diskutil eraseVolume "Free Space" %noformat% /dev/"${backupID}"
		diskutil resizevolume /dev/"${macintoshHDID}" R
else
		if [[ "${coreStorage}" != "" ]] && [[ "$backupIDCS" != "" ]]; then
			echo "Backup partition found and is CoreStorage"
			diskutil cs deleteLVG "${backupUUID}"
			sleep 3
			lvUUID=$(/usr/sbin/diskutil list | grep -A1 "Logical Volume on" | tail -1 | sed -e 's/^[ \t]*//')
			untitledID=$(diskutil list | grep -i "Untitled" | awk '{print $6}')
				echo "Removing Backup partition..."
				diskutil eraseVolume "Free Space" %noformat% /dev/"${untitledID}"
				diskutil cs resizeStack "$lvUUID" 0g
		elif [[ "${coreStorage}" != "" ]] && [[ "$backupIDCS" == "" ]]; then
			lvUUID=$(/usr/sbin/diskutil list | grep -A1 "Logical Volume on" | tail -1 | sed -e 's/^[ \t]*//')
			echo "CoreStorage found but Backup partition not CoreStorage"
			echo "Removing Backup partition..."
			diskutil eraseVolume "Free Space" %noformat% /dev/"${backupID}"
			diskutil cs resizeStack "$lvUUID" 0g
		fi
fi
}


########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$osShort" != "12" ]]; then
	echo "Mac is running ${osFull}, exiting..."
	exit 0
else
	checkLoginStatus
	check365Users
	checkBackupDisk
	stopTMBackup
	removeBackup
fi

exit 0
