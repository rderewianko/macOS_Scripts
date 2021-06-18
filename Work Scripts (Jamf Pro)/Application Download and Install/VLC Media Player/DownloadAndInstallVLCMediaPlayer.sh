#!/bin/zsh

########################################################################
#                Download and Install VLC Media Player                 #
################### Written by Phil Walker May 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Update version
updateVer="3.0.14"
# Get the URL for the DMG
getDMG=$(expr "$(curl -s "https://download.videolan.org/pub/videolan/vlc/${updateVer}/macosx/")" : '.*\(vlc-.*universal.dmg\)')
#getDMG=$(curl --silent "https://download.videolan.org/pub/videolan/vlc/${updateVer}/macosx/" | awk -F "(>|<)" '/.*universal.dmg</{print $3}') # Alt method
# VLC Media Player download URL
downloadURL="https://download.videolan.org/pub/videolan/vlc/${updateVer}/macosx/${getDMG}"
# Download directory
downloadDir="/private/var/tmp/VLCDownload"
# App name
appName="VLC.app"
# Volume name
dmgName="vlc.dmg"

########################################################################
#                            Functions                                 #
########################################################################

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
# If VLC Media Player is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
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
        latestInstallVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of VLC Media Player" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed VLC Media Player ${latestInstallVer}"
        fi
    else
        echo "Failed to install VLC Media Player!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download VLC Media Player, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0