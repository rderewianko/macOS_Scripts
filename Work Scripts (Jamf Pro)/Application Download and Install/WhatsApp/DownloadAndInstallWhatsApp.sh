#!/bin/zsh

########################################################################
#                     Download and Install WhatsApp                    #
################### Written by Phil Walker May 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# WhatsApp download URL
downloadURL=$(curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" "https://web.whatsapp.com/desktop/mac/files/WhatsApp.dmg")
# Download directory
downloadDir="/private/var/tmp/WhatsAppDownload"
# App name
appName="WhatsApp.app"
# Volume name
dmgName="WhatsApp.dmg"

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
# If WhatsApp is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "WhatsApp not currently installed"
fi
# Download WhatsApp DMG
echo "Downloading WhatsApp..."
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
    echo "Installing WhatsApp..."
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
            echo "Reinstalled the same version of WhatsApp" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed WhatsApp ${latestInstallVer}"
        fi
    else
        echo "Failed to install WhatsApp!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download WhatsApp, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0