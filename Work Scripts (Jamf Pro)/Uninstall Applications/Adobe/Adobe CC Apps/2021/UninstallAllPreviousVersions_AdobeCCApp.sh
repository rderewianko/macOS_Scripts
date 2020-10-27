#!/bin/bash

########################################################################
#         Uninstall Previous Versions of an Adobe CC Application       #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Designed to be used when the end user has multiple versions of an Adobe
# CC application installed, including the latest version

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
# Helper Icon legacy versions found
helperIconLegacy="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Unsupported.icns"
# Helper Icon Success
HelperIconSuccess="/System/Library/CoreServices/Installer.app/Contents/PlugIns/Summary.bundle/Contents/Resources/Success.pdf"
# Helper title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="     Legacy ${appNameForRemoval} Removal     "

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
"$jamfHelper" -windowType utility -icon "$helperIconLegacy" -title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "To keep your Mac secure all legacy versions of ${appNameForRemoval} will now be removed.
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

function jamfHelperComplete ()
{
# Updates installed helper
"$jamfHelper" -windowType utility -icon "$HelperIconSuccess" \
-title "$helperTitle" -heading "$helperHeading" -description "All legacy versions of ${appNameForRemoval} removed" \
-alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function removePreviousVersions ()
{
echo "Uninstalling previous verisons of ${appNameForRemoval}..."
# Uninstall 2019
if [[ "$appNameForRemoval" =~ "InCopy" ]] || [[ "$appNameForRemoval" =~ "InDesign" ]]; then
    echo "Policy is for ${appNameForRemoval} so 2019 version will not be removed"
else
    "$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$version2019" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
    uninstallResult2019="$?"
    if [[ "$uninstallResult2019" -eq "0" ]]; then
        echo "${appNameForRemoval} CC 2019 uninstalled"
    fi
    # Confirm the directory has been deleted - manually installed plugins can result in the directory not being removed
    if [[ -d "/Applications/${appNameForRemoval} CC 2019" ]]; then
    rm -rf "/Applications/${appNameForRemoval} CC 2019" >/dev/null 2>&1
    fi
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
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, starting process..."
    # Remove all previous versions
    removePreviousVersions
else
    echo "Jamf helper displayed to ${loggedInUser} to start the process"
    # Advise the user what is happening and get confirmation or run anyway in 2 hours time
    jamfHelperConfirm
    # Jamf Helper for app closure and removal
    jamfHelperCleanUp
    # All a few seconds for the helper message to be seen before closing the apps
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
    jamfHelperComplete
fi
exit 0