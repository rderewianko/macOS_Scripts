#!/bin/bash

########################################################################
#       Adobe CC Application Install Policy Script - Preinstall        #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Must be set to run before the package install
# Process:
# 1. Stop+bootout Adobe Launch Agents/Daemons and kill all Adobe processes
# 2. Uninstall all previous versions of the application being installed

# Edit for 2021 app releases

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# App sap code (https://helpx.adobe.com/enterprise/kb/apps-deployed-without-base-versions.html)
sapCode="$4"
# CC app name e.g Adobe Photoshop
appNameForRemoval="$5"
# base version (https://helpx.adobe.com/enterprise/kb/apps-deployed-without-base-versions.html)
version2019="$6"
version2020="$7"
# CC App name for helper windows e.g. Adobe Photoshop 2021
appNameForInstall="$8"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ -d "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app" ]]; then
    # Helper Icon Cloud Uninstaller
    helperIcon="/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app/Contents/Resources/CreativeCloudInstaller.icns"
else
    # helper Icon SS
    helperIcon="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
fi
# Helper icon Download
helperIconDownload="/System/Library/CoreServices/Install in Progress.app/Contents/Resources/Installer.icns"
# Helper title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="          ${appNameForInstall}          "

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
else
    # Get all user Adobe Launch Agents/Daemons PIDs
    userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
    # Kill all user Adobe Launch Agents/Daemons
    if [[ "$userPIDs" != "" ]]; then
        while IFS= read -r line; do
            kill -9 "$line" 2>/dev/null
        done <<< "$userPIDs"
    fi
    # Bootout all user Adobe Launch Agents
    launchctl bootout gui/"$loggedInUserID" /Library/LaunchAgents/com.adobe.* 2>/dev/null
    # Bootout Adobe Launch Daemons
    launchctl bootout system /Library/LaunchDaemons/com.adobe.* 2>/dev/null
    pkill -9 "obe"
    sleep 5
    # Close any Adobe Crash Reporter windows (e.g. Bridge)
    pkill -9 "Crash Reporter"
fi
}

function jamfHelperCleanUp ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Closing all Adobe CC applications and uninstalling all previous versions of ${appNameForRemoval}..." -alignDescription natural &
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appNameForInstall}...

⚠️ Please do not open any Adobe CC app ⚠️

            ⏱ Download time will vary ⏱" -alignDescription natural &
}

########################################################################
#                         Script starts here                           #
########################################################################

# jamf Helper for killing apps and uninstalling previous versions
jamfHelperCleanUp
# Wait a few seconds for the helper message to be seen before closing the apps
sleep 5
# Kill processes to allow uninstall
killAdobe
# Wait before uninstalling
sleep 10
echo "Uninstalling previous verisons of ${appNameForRemoval}..."
# Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2019" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2019="$?"
if [[ "$uninstallResult2019" -eq "0" ]]; then
    echo "${appNameForRemoval} CC 2019 uninstalled"
fi
# Confirm the directory has been deleted - manually installed plugins can result in the directory not being removed
if [[ -d "/Applications/${appNameForRemoval} CC 2019" ]]; then
    rm -rf "/Applications/${appNameForRemoval} CC 2019" >/dev/null 2>&1
fi
# Uninstall 2020
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2020" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2020="$?"
if [[ "$uninstallResult2020" -eq "0" ]]; then
    echo "${appNameForRemoval} 2020 uninstalled"
fi
# Confirm the directory has been deleted - manually installed plugins can result in the directory not being removed
if [[ -d "/Applications/${appNameForRemoval} 2020" ]]; then
    rm -rf "/Applications/${appNameForRemoval} 2020" >/dev/null 2>&1
fi
# Kill the cleaning up helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Jamf Helper for app download+install
jamfHelperDownloadInProgress

exit 0