#!/bin/zsh

########################################################################
#  Download and Install Application (Source: DMG) (Self Service Only)  #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Application Name - must match exact name of the application bundle without the extension e.g. Slack
appName="$4"
# Download URL
targetURL="$5"
############ Variables for Jamf Pro Parameters - End ###################

# Destination Download URL
downloadURL=$(curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" "$targetURL")
# Download directory
downloadDir="/private/var/tmp/${appName}Download"
# jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon Download
helperIconDownload="/System/Library/CoreServices/Install in Progress.app/Contents/Resources/Installer.icns"
# Helper title
helperTitle="Message From Bauer Technology"
# Helper heading
helperHeading="          ${appName}          "
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appName}...

            ⏱ Download time will vary ⏱" -alignDescription natural &
}

function jamfHelperInstallComplete ()
{
# Install complete helper
"$jamfHelper" -windowType utility -icon "$helperIconComplete" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${appName} Installation Complete ✅" -alignDescription natural -timeout 10 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${appName} Installation Failed ⚠️

Please reboot your Mac and try installing ${appName} from Self Service again." -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
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
# If the app is installed, get the version number for comparison
if [[ -d "/Applications/${appName}.app" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "${appName} not currently installed"
fi
# Download DMG
echo "Downloading ${appName}..."
curl --silent --output "${downloadDir}/${appName}.dmg" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
if [[ -f "${downloadDir}/${appName}.dmg" ]]; then
    # Remove the previous version
    if [[ -d "/Applications/${appName}.app" ]]; then
        rm -rf "/Applications/${appName}.app"
        if [[ ! -d "/Applications/${appName}.app" ]]; then
            echo "Previous version removed"
        else
            echo "Failed to remove previous version"
        fi
    fi
    echo "Installing ${appName}..."
    # Mount the DMG
    appVolume=$(hdiutil attach -nobrowse "${downloadDir}/${appName}.dmg" | grep /Volumes | sed -e 's/^.*\/Volumes\///g')
    sleep 2
    # Copy the new version
    ditto -rsrc "/Volumes/${appVolume}/${appName}.app" "/Applications/${appName}.app"
    sleep 2
    # Unmount the volume
    hdiutil unmount -force "/Volumes/$appVolume" &>/dev/null
    # Wait a few seconds before checking the installed version
    sleep 2
    if [[ -d "/Applications/${appName}.app" ]]; then
        # Remove the quarantine attribute
        xattr -rd com.apple.quarantine "/Applications/${appName}.app" &>/dev/null
        # Set the correct ownership
        chown -R root:wheel "/Applications/${appName}.app"
        # Check the version
        latestInstallVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of ${appName}" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed ${appName} ${latestInstallVer}"
        fi
    else
        echo "Failed to install ${appName}!"
        # Kill previous helper and show a failure helper
        failureKillHelper
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download ${appName}, exiting!"
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