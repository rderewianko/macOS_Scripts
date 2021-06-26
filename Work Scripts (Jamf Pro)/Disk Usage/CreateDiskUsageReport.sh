#!/bin/zsh

########################################################################
#                      Create A Disk Usage Report                      #
#################### Written by Phil Walker Apr 2021 ###################
########################################################################
# Designed to be used in a Self Service policy

# Before defining the variables open jamfHelper to show the user the task is in progress
"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -icon \
"/System/Applications/Utilities/Disk Utility.app/Contents/Resources/AppIcon.icns" -title "Message from Bauer Technology" \
-heading "Disk Usage Report" -alignHeading natural -description "⏳ Creating Disk Usage Report ⏳"  -alignDescription natural &

########################################################################
#                            Variables                                 #
########################################################################

# Logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Boot volume total size
bootDriveTotal=$(df -kH / | awk '{print $2}' | tail -1)
# Boot volume available space
bootDriveAvailable=$(df -kH / | awk '{print $4}' | tail -1)
# Logged in users directories
if [[ -d "/Users/${loggedInUser}/Bauer Media Group" ]]; then
	# OneDrive Shared content (SharePoint document libraries/folders synced)
    bmgUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Bauer Media Group" | awk '{print $1}')
    bmgUsage=$(du -hd0 "/Users/${loggedInUser}/Bauer Media Group/"* | sort -hr | sed -n 1,10p)
fi
# Desktop
desktopUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Desktop" | awk '{print $1}')
desktopUsage=$(du -hd0 "/Users/${loggedInUser}/Desktop/"* | sort -hr | sed -n 1,10p)
# Documents
documentsUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Documents" 2>/dev/null | awk '{print $1}')
documentsUsage=$(du -hd0 "/Users/${loggedInUser}/Documents/"* 2>/dev/null | sort -hr | sed -n 1,10p)
# Downloads
downloadsUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Downloads" 2>/dev/null | awk '{print $1}')
downloadsUsage=$(du -hd0 "/Users/${loggedInUser}/Downloads/"* 2>/dev/null | sort -hr | sed -n 1,10p)
# User Library
libraryUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Library" 2>/dev/null | awk '{print $1}')
libraryUsage=$(du -hd1 "/Users/${loggedInUser}/Library" 2>/dev/null | sed '$d' | sort -hr | sed -n 1,10p)
# Movies
moviesUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Movies" 2>/dev/null | awk '{print $1}')
moviesUsage=$(du -hd0 "/Users/${loggedInUser}/Movies/"* 2>/dev/null | sort -hr | sed -n 1,10p)
# Music
musicUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Music" 2>/dev/null | awk '{print $1}')
musicUsage=$(du -hd0 "/Users/${loggedInUser}/Music/"* 2>/dev/null | sort -hr | sed -n 1,10p)
# Find the correct OneDrive Sync directory
oldFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Group"
newFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Media Group"
if [[ -d "$oldFolderPath" ]] && [[ ! -d "$newFolderPath" ]]; then
    OneDriveSync="$oldFolderPath"
elif [[ ! -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    OneDriveSync="$newFolderPath"
elif [[ -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
    OneDriveSync="$newFolderPath"
else
    OneDriveSync=""
fi
# Check OneDrive Sync usage
if [[ "$OneDriveSync" != "" ]]; then
    onedriveUsageTotal=$(du -hd0 "$OneDriveSync" | awk '{print $1}')
    onedriveUsage=$(du -hd0 "${OneDriveSync}/"* | sort -hr | sed -n 1,10p)
fi
# Pictures
picturesUsageTotal=$(du -hd0 "/Users/${loggedInUser}/Pictures" 2>/dev/null | awk '{print $1}')
picturesUsage=$(du -hd0 "/Users/${loggedInUser}/Pictures/"* 2>/dev/null | sort -hr | sed -n 1,10p)
# System level directories
libraryUsageTotal=$(du -hd0 /Library 2>/dev/null | awk '{print $1}')
applicationUsageTotal=$(du -hd0 /Applications | awk '{print $1}')
usersUsageTotal=$(du -hd0 /Users | awk '{print $1}')
userUsage=$(du -hd0 /Users/* | grep -v "admin" | sort -hr)
# Date and time
datetime=$(date +"%d-%m-%Y_%H-%M-%S")
# Usage Report
usageReport="/Users/${loggedInUser}/Desktop/DiskUsageReport_${datetime}.txt"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

# Find correct format for real name of logged in user
function getRealName ()
{
# If Jamf Connect is installed try to get the value from the Jamf Connect state settings
if [[ -f "/Users/${loggedInUser}/Library/Preferences/com.jamf.connect.state.plist" ]]; then
	userRealName=$(sudo -u "$loggedInUser" defaults read com.jamf.connect.state UserCN 2>/dev/null)
	if [[ "$userRealName" == "" ]]; then
		# If no value is found then use the value from Directory Service
		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $2, $1}' | xargs)
	fi
else
	# Logged in users ID
	loggedInUserID=$(id -u "$loggedInUser")
	if [[ "$loggedInUser" =~ "admin" ]];then
		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $1, $2, $3}' | xargs)
	else
		if [[ "$loggedInUserID" -lt "1000" ]]; then
			userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $1, $2}' | xargs)
  		else
    		userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk -F, '{print $2, $1}' | xargs)
  		fi
	fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

getRealName
# Create usage report file
if [[ ! -f "$usageReport" ]]; then
    runAsUser touch "$usageReport"
    if [[ ! -f "$usageReport" ]]; then
        echo "Failed to create usage report file, exiting"
        exit 1
    fi
fi
echo "Creating disk usage report..."
# Output everything to the usage report
exec 3>&1 1>"$usageReport"
runAsUser echo "-------------------DISK USAGE REPORT-------------------"
runAsUser echo ""
runAsUser echo "#######################################################"
runAsUser echo "                 Disk size and space                   "
runAsUser echo "#######################################################"
runAsUser echo ""
runAsUser echo "Disk Size: ${bootDriveTotal}"
runAsUser echo "Available Space: ${bootDriveAvailable}"
runAsUser echo ""
runAsUser echo "#######################################################"
runAsUser echo "                 System level usage                    "
runAsUser echo "#######################################################"
runAsUser echo ""
runAsUser echo "Library: ${libraryUsageTotal}"
runAsUser echo "Applications: ${applicationUsageTotal}"
runAsUser echo "Users: ${usersUsageTotal}"
runAsUser echo ""
runAsUser echo "#######################################################"
runAsUser echo "                  All User Profiles                    "
runAsUser echo "#######################################################"
runAsUser echo ""
runAsUser echo "${userUsage}"
runAsUser echo ""
runAsUser echo "#######################################################"
runAsUser echo "       ${userRealName}'s user profile usage            "
runAsUser echo "#######################################################"
runAsUser echo ""
runAsUser echo "OneDrive Shared Content (Downloaded): ${bmgUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${bmgUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Desktop Total: ${desktopUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${desktopUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Documents Total: ${documentsUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${documentsUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Downloads Total: ${downloadsUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${downloadsUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "User Library Total: ${libraryUsageTotal}"
runAsUser echo "Largest Folders"
runAsUser echo "${libraryUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Movies Total: ${moviesUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${moviesUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Music Total: ${musicUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${musicUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "OneDrive Total (Downloaded): ${onedriveUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${onedriveUsage}"
runAsUser echo "-------------------------------------------------------"
runAsUser echo "Pictures Total: ${picturesUsageTotal}"
runAsUser echo "Largest Folders and Files"
runAsUser echo "${picturesUsage}"
runAsUser echo "-------------------------------------------------------"
# Restore logging to default
exec 1>&3 3>&-
# Kill in progress helper window
killall -13 jamfHelper 2>/dev/null
# Check the report has been created and is readable
if [[ -f "$usageReport" ]] && [[ -r "$usageReport" ]]; then
    echo "Usage report created and readable"
    echo "Usage report location: ${usageReport}"
else
    echo "Failed to created usage report"
    exit 1
fi
# Open the text file
runAsUser open -a TextEdit "$usageReport"
exit 0