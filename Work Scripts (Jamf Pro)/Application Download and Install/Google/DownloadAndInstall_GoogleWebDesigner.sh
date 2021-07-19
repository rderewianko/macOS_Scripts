#!/bin/zsh

########################################################################
#        Download and Install Google Web Designer (Source: DMG)        #
################### Written by Phil Walker June 2021 ###################
########################################################################
# Source must be a DMG containing the application bundle

########################################################################
#                            Variables                                 #
########################################################################

# Application Name - must match exact name of the application bundle without the extension
appName="Google Web Designer"
# Target URL
targetURL="https://dl.google.com/webdesigner/mac/shell/googlewebdesigner_mac.dmg"
# Destination Download URL
downloadURL=$(curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" "$targetURL")
# Download directory
downloadDir="/private/var/tmp/${appName}Download"

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
        latestInstallVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString 2>/dev/null)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of ${appName}" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed ${appName} ${latestInstallVer}"
        fi
    else
        echo "Failed to install ${appName}!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download ${appName}, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0