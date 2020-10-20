#!/bin/bash

########################################################################
# Adobe Creative Cloud Application Upgrade Policy Script - Preinstall  #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Designed to be used with an Adobe CC app installation policy to upgrade
# an end users version of a CC app to the latest version.
# Must be set to run before the package install

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# App sap code
sapCode="$4"
# CC app name
appNameForRemoval="$5"
# base version
version2015="$6"
version2017="$7"
version2018="$8"
version2019="$9"
# CC App name for helper windows e.g. Adobe Photoshop 2020
appNameForInstall="${10}"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
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
helperHeading="     Upgrade to ${appNameForInstall}     "

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
# Get all user Adobe Launch Agents/Daemons PIDs
userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
# Kill all user Adobe Launch Agents/Daemons
if [[ "$userPIDs" != "" ]]; then
    while IFS= read -r line; do
        kill -9 "$line" 2>/dev/null
    done <<< "$userPIDs"
fi
# Unload user Adobe Launch Agents
su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"
# Unload Adobe Launch Daemons
/bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null
pkill -9 "obe" >/dev/null 2>&1
sleep 5
# Close any Adobe Crash Reporter windows (e.g. Bridge)
pkill -9 "Crash Reporter" >/dev/null 2>&1
}

function jamfHelperConfirm ()
{
# Show a message via Jamf Helper that the update is ready, this is after it has been deferred
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "To keep your Mac secure ${appNameForRemoval} will now be upgraded to the latest version (All previous versions will be removed).
For this to complete successfully all Adobe CC applications must be closed during the process.

Please save all of your work before clicking Start" -timeout 7200 -countdown -alignCountdown center -button1 "Start" -defaultButton "1"
}

function jamfHelperCleanUp ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Closing all Adobe CC applications and uninstalling all legacy versions of ${appNameForRemoval}..." \
-alignDescription natural &
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appNameForInstall}...

⚠️ Please do not open any Adobe CC app ⚠️

** Download time will depend on the speed of your current internet connection **" -alignDescription natural &
}

function removePreviousVersions ()
{
echo "Uninstalling previous verisons of ${appNameForRemoval}..."
# Uninstall 2015 - Look for 2015.1-5 first as they can be uninstalled via command line
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2015" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2015="$?"
if [[ "$uninstallResult2015" -eq "0" ]]; then
    echo "${appNameForRemoval} 2015 uninstalled"
fi
# if version 2015 is installed then the directory must be removed
if [[ -d "/Applications/${appNameForRemoval} 2015" ]]; then
    rm -rf "/Applications/${appNameForRemoval} 2015" >/dev/null 2>&1
    sleep 2
    # Sometimes the directory stays behind empty so delete again to make sure
    rm -rf "/Applications/${appNameForRemoval} 2015" >/dev/null 2>&1
    if [[ ! -d "/Applications/${appNameForRemoval} 2015" ]]; then
        echo "${appNameForRemoval} 2015 uninstalled"
    fi
fi
# Uninstall 2017
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2017" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2017="$?"
if [[ "$uninstallResult2017" -eq "0" ]]; then
    echo "${appNameForRemoval} 2017 uninstalled"
fi
rm -rf "/Applications/${appNameForRemoval} 2017" >/dev/null 2>&1
# Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2018" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2018="$?"
if [[ "$uninstallResult2018" -eq "0" ]]; then
    echo "${appNameForRemoval} 2018 uninstalled"
fi
rm -rf "/Applications/${appNameForRemoval} 2018" >/dev/null 2>&1
# Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2019" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
uninstallResult2019="$?"
if [[ "$uninstallResult2019" -eq "0" ]]; then
    echo "${appNameForRemoval} 2019 uninstalled"
fi
rm -rf "/Applications/${appNameForRemoval} 2019" >/dev/null 2>&1
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, starting upgrade..."
    # Remove all previous versions
    removePreviousVersions
else
    echo "Jamf helper displayed to ${loggedInUser} to start the upgrade process"
    # Advise the user what is happening and get confirmation or run anyway in 2 hours time
    jamfHelperConfirm
    # Jamf Helper for app closure and removal
    jamfHelperCleanUp
    # Wait a few seconds for the helper message to be seen before closing the apps
    sleep 5
    # Kill processes to allow uninstall
    killAdobe
    # Wait before uninstalling
    sleep 10
    # Remove all previous versions
    removePreviousVersions
    # Kill the cleaning up helper
    killall -13 "jamfHelper" >/dev/null 2>&1
    # Jamf Helper for app download+install
    jamfHelperDownloadInProgress
fi
exit 0