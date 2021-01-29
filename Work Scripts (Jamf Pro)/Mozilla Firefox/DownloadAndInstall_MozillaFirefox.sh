#!/bin/zsh

########################################################################
#  Download and install the latest Mozilla Firefox Enterprise Package  #
################### Written by Phil Walker Jan 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Set language
lang="en-GB"
# Get OS version and adjust for use with the URL string
osVersURL=$(sw_vers -productVersion | sed 's/[.]/_/g')
# Set the User Agent string for use with curl
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${osVersURL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"
# Get the latest version of Firefox available from Firefox page.
latestVersion=$(/usr/bin/curl -s -A "$userAgent" https://www.mozilla.org/${lang}/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}')
# Download directory
downloadDir="/private/var/tmp/FirefoxDownload"
# Package name
pkgFile="UK_Mozilla_Firefox_${latestVersion}.pkg"
# Download URL
downloadURL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestVersion}/mac/${lang}/Firefox%20${latestVersion}.pkg"

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
# Print the version and URL
echo "Latest version of Firefox is: $latestVersion"
echo "URL for the latest version is: $downloadURL"
# If Firefox is installed, get the version number for comparison
if [[ -d "/Applications/Firefox.app" ]]; then
	currentInstalledVer=$(/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString)
	echo "Current installed version is: $currentInstalledVer"
    if [[ "$currentInstalledVer" == "$latestVersion" ]]; then
        echo "Reinstalling the same version of Mozilla Firefox" # This is pretty much pointless but we'll do it anyway
    else
        echo "Upgrading Mozilla Firefox from ${currentInstalledVer} to version ${latestVersion}"
    fi
else
    echo "Firefox not currently installed"
fi
# Download, install and then report the installed version
echo "Downloading package for Firefox version ${latestVersion}..."
curl -s -o "${downloadDir}/${pkgFile}" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
if [[ -e "${downloadDir}/${pkgFile}" ]]; then
    echo "Firefox version ${latestVersion} downloaded to ${downloadDir}"
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
    if [[ -d "/Applications/Firefox.app" ]]; then
        currentInstalledVer=$(/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString)
        echo "Successfully installed Mozilla Firefox version: ${currentInstalledVer}"
    else
        echo "Failed to install Mozilla Firefox!"
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