#!/bin/zsh

########################################################################
#                Download and Install Visual Studio Code               #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Visual Studio Code download URL
downloadURL=$(curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal")
# Download directory
downloadDir="/private/var/tmp/VSCodeDownload"
# App name
appName="Visual Studio Code.app"
# Zip name
zipName="VSCode.zip"

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
# If Visual Studio Code is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "Visual Studio Code not currently installed"
fi
# Download Visual Studio Code ZIP
echo "Downloading Visual Studio Code..."
curl --silent --output "${downloadDir}/${zipName}" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
# Unzip the download
unzip -q "${downloadDir}/${zipName}" -d "$downloadDir"
sleep 2
if [[ -d "${downloadDir}/${appName}" ]]; then
    # Remove the previous version
    if [[ -d "/Applications/${appName}" ]]; then
        rm -rf "/Applications/${appName}"
        if [[ ! -d "/Applications/${appName}" ]]; then
            echo "Previous version removed"
        else
            echo "Failed to remove previous version"
        fi
    fi
    echo "Installing Visual Studio Code ${updateVer}..."
    # Copy the new version
    ditto -rsrc "${downloadDir}/${appName}" "/Applications/${appName}"
    if [[ -d "/Applications/${appName}" ]]; then
        # Remove the quarantine attribute
        xattr -rd com.apple.quarantine "/Applications/${appName}" &>/dev/null
        # Set the correct ownership
        chown -R root:wheel "/Applications/${appName}"
        # Check the version
        latestInstallVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of Visual Studio Code" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed Visual Studio Code ${latestInstallVer}"
        fi
    else
        echo "Failed to install Visual Studio Code!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download Visual Studio Code, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0