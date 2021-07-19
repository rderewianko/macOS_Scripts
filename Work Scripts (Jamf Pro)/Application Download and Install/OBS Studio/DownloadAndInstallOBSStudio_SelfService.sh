#!/bin/zsh

########################################################################
#          Download and Install OBS Studio (Self Service Only)         #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Update version
updateVer="$4"
# App to be installed
helperAppName="$5"
############ Variables for Jamf Pro Parameters - End ###################

# OBS Studio download URL
downloadURL="https://cdn-fastly.obsproject.com/downloads/obs-mac-${updateVer}.dmg"
# Download directory
downloadDir="/private/var/tmp/OBSDownload"
# App name
appName="OBS.app"
# Volume name
dmgName="obs.dmg"
# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# User preferences directory
userPrefDir="/Users/${loggedInUser}/Library/Application Support/obs-studio"
# jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon Download
helperIconDownload="/System/Library/CoreServices/Install in Progress.app/Contents/Resources/Installer.icns"
# Helper title
helperTitle="Message From Bauer Technology"
# Helper heading
helperHeading="          ${helperAppName}          "
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"

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

function userPrefs ()
{
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to set user preferences"
else
    if [[ -d "$userPrefDir" ]]; then
        echo "User preferences already set, nothing will be changed"
    else
        runAsUser mkdir -p "$userPrefDir"
        if [[ -d "$userPrefDir" ]]; then
            runAsUser echo "[General]" >> "${userPrefDir}/global.ini"
            runAsUser echo "LicenseAccepted=true" >> "${userPrefDir}/global.ini"
            runAsUser echo "EnableAutoUpdates=false" >> "${userPrefDir}/global.ini"
            postCheck=$(cat "${userPrefDir}/global.ini" | grep "EnableAutoUpdates=false")
            if [[ "$postCheck" == "EnableAutoUpdates=false" ]]; then
                echo "Default user preferences set"
            else
                echo "Failed to set default user preferences, auto updates will need to be manually disabled"
            fi
        else
            echo "Failed to create user preference directory, unable to set default preferences"
        fi
    fi
fi
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${helperAppName}...

⏱ Download time will vary ⏱" -alignDescription natural &
}

function jamfHelperInstallComplete ()
{
# Install complete helper
"$jamfHelper" -windowType utility -icon "$helperIconComplete" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${helperAppName} Installation Complete ✅" -alignDescription natural -timeout 10 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${helperAppName} Installation Failed ⚠️

Please reboot your Mac and try installing ${helperAppName} from Self Service again." -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function failureKillHelper ()
{
# Kill the download helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Show the failure helper
jamfHelperFailed
}

function cleanUp ()
{
# Remove temp directory
if [[ -d "$downloadDir" ]]; then
    rm -rf "$downloadDir"
    if [[ ! -d "$downloadDir" ]]; then
        echo "Removed all temp content"
    else
        echo "Failed to remove temp content"
    fi
else
    echo "No temp content found, nothing to do"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Create the temporary directory
mkdir "$downloadDir"
# Jamf Helper for download in progress
jamfHelperDownloadInProgress
# If OBS Studio is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "OBS Studio not currently installed"
fi
# Download OBS Studio DMG
echo "Downloading OBS Studio ${updateVer}..."
curl --silent --output "${downloadDir}/${dmgName}" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
if [[ -f "${downloadDir}/${dmgName}" ]]; then
    # Remove the previous version
    if [[ -d "/Applications/${appName}" ]]; then
        rm -rf "/Applications/${appName}"
        if [[ ! -d "/Applications/${appName}" ]]; then
            echo "Previous version removed"
        else
            echo "Failed to remove previous version"
        fi
    fi
    echo "Installing OBS Studio ${updateVer}..."
    # Mount the DMG
    appVolume=$(hdiutil attach -nobrowse "${downloadDir}/${dmgName}" | grep /Volumes | sed -e 's/^.*\/Volumes\///g')
    sleep 2
    # Copy the new version
    ditto -rsrc "/Volumes/${appVolume}/${appName}" "/Applications/${appName}"
    sleep 2
    # Unmount the volume
    umount "/Volumes/$appVolume"
    # Wait a few seconds before checking the installed version
    sleep 2
    if [[ -d "/Applications/${appName}" ]]; then
        # Set the correct ownership
        chown -R root:wheel "/Applications/${appName}"
        # Check the version
        latestInstallVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of OBS Studio" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed OBS Studio ${latestInstallVer}"
        fi
        # Set the default user preferences - disable auto updates
        userPrefs
    else
        echo "Failed to install OBS Studio!"
        # Kill previous helper and show a failure helper
        failureKillHelper
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download OBS Studio, exiting!"
    # Kill previous helper and show a failure helper
    failureKillHelper
    # Remove temp content
    cleanUp
    exit 1
fi
# Kill the download helper
killall -13 "jamfHelper" &>/dev/null
# Define helper complete icon. This is defined later so that the app icon can be used post install
helperIconComplete="$6" # defined as a parameter in Jamf Pro
if [[ ! -e "$helperIconComplete" ]]; then
    helperIconComplete="/System/Library/CoreServices/Installer.app/Contents/PlugIns/Summary.bundle/Contents/Resources/Success.pdf"
fi
# Install success helper
jamfHelperInstallComplete
# Remove temp content
cleanUp
exit 0