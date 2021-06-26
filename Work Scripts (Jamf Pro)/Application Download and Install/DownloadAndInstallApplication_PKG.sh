#!/bin/zsh

########################################################################
#             Download and Install Applications (Source: PKG)          #
################### Written by Phil Walker June 2021 ###################
########################################################################
# Designed to be used in a Payload-Free Package
# Source must be a PKG

########################################################################
#                            Variables                                 #
########################################################################

# Application Name - must match exact name of the application bundle without the extension e.g. Slack
appName="Microsoft Edge"
# Download URL
downloadURL="https://go.microsoft.com/fwlink/?linkid=2093504"
# Target package
targetPKG=$(curl --head --location --silent "$downloadURL" | grep -i "location" | grep -i ".pkg" | awk -F '/' '{print $NF}' | tr -d '\r')
# Target package size - Some apps return multiple headers, find the Content-Length that isn't 0
targetPKGSizeCheck=$(curl --head --location --silent "$downloadURL" | grep -i "Content-Length" | grep -v "Access-Control-Expose-Headers" | sed 's/[^0-9]//g')
for pkgSize in ${(f)targetPKGSizeCheck}; do
    if [[ "$pkgSize" -ne "0" ]]; then
        targetPKGSize="$pkgSize"
    fi
done
# Download directory
downloadDir="/private/var/tmp/PKGDownload"

########################################################################
#                            Functions                                 #
########################################################################

function cleanUp ()
{
# Remove the temporary working directory when done
rm -rf "$tempDirectory"
echo "Deleting temporary directory '$tempDirectory' and its contents"
if [[ ! -d "$tempDirectory" ]]; then
    echo "Temporary directory deleted"
else
    echo "Failed to delete the temporary directory"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Create a temporary working directory
echo "Creating temporary directory for the download"
tempDirectory=$(mktemp -d "/private/tmp/AppDownload.XXXXXX")
echo "Target package: $targetPKG"
echo "Target package size: $targetPKGSize bytes"
# If the app is installed, get the version number for comparison
if [[ -d "/Applications/${appName}.app" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString 2>/dev/null)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "${appName} not currently installed"
fi
# Download the installer package
echo "Downloading ${appName} package..."
curl --location --silent "$downloadURL" -o "${tempDirectory}/${targetPKG}"
# Check if the download completed
downloadedPKG=$(stat -f%z "${tempDirectory}/${targetPKG}")
echo "Downloaded package size: ${downloadedPKG} bytes"
if [[ "$targetPKGSize" -eq "$downloadedPKG" ]]; then
    echo "Target package and downloaded package file sizes match"
    echo "${appName} download complete"
else
    echo "Failed to download the package, exiting..."
    # Remove temp content
    cleanUp
    exit 1
fi
echo "Installing ${appName}..."
installer -pkg "${tempDirectory}/${targetPKG}" -target /
# Wait a few seconds before checking the installed version
sleep 2
if [[ -d "/Applications/${appName}.app" ]]; then
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
# Remove temp content
cleanUp
exit 0