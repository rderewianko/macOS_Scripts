#!/bin/bash

########################################################################
#         Adobe Acrobat DC Install Policy Script - Preinstall          #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Must be set to run before the package install
# Process:
# Stop+unload Adobe Launch Agents/Daemons and kill all Adobe processes

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# CC App name for helper windows e.g. Adobe Acrobat DC
appNameForInstall="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
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
    # Kill all user Adobe Launch Agents and Daemons
    if [[ "$userPIDs" != "" ]]; then
        while IFS= read -r line; do
            kill -9 "$line" 2>/dev/null
        done <<< "$userPIDs"
    fi
    # Unload user Adobe Launch Agents
    su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"
    # Unload Adobe Launch Daemons
    /bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null
    pkill "obe" >/dev/null 2>&1
    sleep 5
    # Close any Adobe Crash Reporter windows (e.g. Bridge)
    pkill -9 "Crash Reporter" >/dev/null 2>&1
    # Kill Safari processes - can cause install failure (Error DW046 - Conflicting processes are running)
    killall -9 "Safari" >/dev/null 2>&1
fi
}

function jamfHelperCleanUp ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Closing all Adobe CC applications and Safari..." -alignDescription natural &
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
# Kill the cleaning up helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Jamf Helper for app download+install
jamfHelperDownloadInProgress

exit 0