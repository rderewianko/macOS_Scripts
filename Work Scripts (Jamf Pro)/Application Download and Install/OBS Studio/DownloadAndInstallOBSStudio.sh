#!/bin/zsh

########################################################################
#                    Download and Install OBS Studio                   #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Update version
updateVer="27.0.1"
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
# If OBS Studio is installed, get the version number for comparison
if [[ -d "/Applications/${appName}" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}/Contents/Info CFBundleShortVersionString 2>/dev/null)
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
            echo "Reinstalled the same version of OBS Studio" # This is pretty much pointless but we did it anyway
        else
            echo "Successfully installed OBS Studio ${latestInstallVer}"
        fi
        # Set the default user preferences - disable auto updates
        userPrefs
    else
        echo "Failed to install OBS Studio!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download OBS Studio, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0