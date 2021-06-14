#!/bin/zsh

########################################################################
#      Download and Install VLC Media Player (Self Service Only)       #
################### Written by Phil Walker May 2021 ####################
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

# Get the URL for the DMG
getDMG=$(expr "$(curl -s "https://download.videolan.org/pub/videolan/vlc/${updateVer}/macosx/")" : '.*\(vlc-.*universal.dmg\)')
# VLC Media Player download URL
downloadURL="https://download.videolan.org/pub/videolan/vlc/${updateVer}/macosx/${getDMG}"
# Download directory
downloadDir="/private/var/tmp/VLCDownload"
# App name
appName="VLC.app"
# Volume name
dmgName="vlc.dmg"
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
killall -13 "jamfHelper" &>/dev/null
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
# If VLC Media Player is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "VLC Media Player not currently installed"
fi
# Download VLC Media Player DMG
echo "Downloading VLC Media Player ${updateVer}..."
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
    echo "Installing VLC Media Player ${updateVer}..."
    # Mount the DMG
    appVolume=$(hdiutil attach -nobrowse "${downloadDir}/${dmgName}" | grep /Volumes | sed -e 's/^.*\/Volumes\///g')
    sleep 2
    # Copy the new version
    ditto -rsrc "/Volumes/${appVolume}/${appName}" "/Applications/${appName}"
    sleep 2
    # Unmount the volume
    hdiutil unmount -force "/Volumes/$appVolume" &>/dev/null
    # Wait a few seconds before checking the installed version
    sleep 2
    if [[ -d "/Applications/${appName}" ]]; then
        # Remove the quarantine attribute
        xattr -rd com.apple.quarantine "/Applications/${appName}" &>/dev/null
        # Set the correct ownership
        chown -R root:wheel "/Applications/${appName}"
        # Check the version
        latestInstallVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of VLC Media Player" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed VLC Media Player ${latestInstallVer}"
        fi
    else
        echo "Failed to install VLC Media Player!"
        # Kill previous helper and show a failure helper
        failureKillHelper
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download VLC Media Player, exiting!"
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