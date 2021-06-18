#!/bin/zsh

########################################################################
#   Download and Install the Latest Google Chrome Enterprise Package   #
################### Written by Phil Walker Aug 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Chrome download URL with terms accepted
downloadURL="https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg"
# Set the package name
pkgFile="Global_Google_Chrome.pkg"
# Download directory
downloadDir="/private/var/tmp/ChromeDownload"

########################################################################
#                            Variables                                 #
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
# If Chrome is installed, get the version number for comparison
if [[ -d "/Applications/Google Chrome.app" ]]; then
	currentInstalledVer=$(/usr/bin/defaults read /Applications/Google\ Chrome.app/Contents/Info CFBundleShortVersionString)
	echo "Current installed version is: $currentInstalledVer"
else
    echo "Google Chrome not currently installed"
fi
# Download Google Chrome Enterprise package
echo "Downloading Google Chrome Enterprise package..."
curl -s -o "${downloadDir}/${pkgFile}" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
if [[ -e "${downloadDir}/${pkgFile}" ]]; then
    echo "Latest Google Chrome package downloaded to ${downloadDir}"
    echo "Starting install..."
    /usr/sbin/installer -pkg "${downloadDir}/${pkgFile}" -target /
    # Check install result
    commandResult="$?"
    if [[ "$commandResult" -ne "0" ]]; then
        echo "Install failed!"
        # Remove temp content
        cleanUp
        exit 1
    fi
    # Wait a few seconds before checking the installed version
    sleep 2
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        latestInstallVer=$(/usr/bin/defaults read /Applications/Google\ Chrome.app/Contents/Info CFBundleShortVersionString)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of Google Chrome" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed Google Chrome version: ${latestInstallVer}"
        fi
    else
        echo "Failed to install Google Chrome!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Package download failed!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0