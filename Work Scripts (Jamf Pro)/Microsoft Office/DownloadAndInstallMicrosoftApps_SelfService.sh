#!/bin/zsh

########################################################################
#              Download and Install Microsoft Applications             #
#                     (Self Service only version)                      #
########################################################################

# Credit to Written William Smith (Professional Services Engineer @Jamf bill@talkingmoose.net
# https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a
# Edited by Phil Walker Jan 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Microsoft fwlink (permalink) product ID e.g. "2009112" for Office 365 Business Pro
linkID="$4"
# 525133 - Office 2019 for Mac SKUless download (aka Office 365)
# 2009112 - Office 365 for Mac Business Pro SKUless download (aka Office 365 with Teams)
# 830196 - AutoUpdate download
# 2093438 - Edge (Enterprise Stable)
# 2093294 - Edge (Enterprise Beta)
# 2093292 - Edge (Enterprise Dev)
# 525135 - Excel 2019 SKUless download
# 869655 - InTune Company Portal download
# 823060 - OneDrive download
# 820886 - OneNote download
# 525137 - Outlook 2019 SKUless download
# 525136 - PowerPoint 2019 SKUless download
# 868963 - Remote Desktop
# 800050 - SharePoint Plugin download
# 832978 - Skype for Business download
# 869428 - Teams
# 525134 - Word 2019 SKUless download
# sha256 Checksum e.g. "67b1e8e036c575782b1c9188dd48fa94d9eabcb81947c8632fd4acac7b01644b"
sha256Checksum="$5" # This is not required. Install will start with no value in this parameter.
# Package Name
pkgName="$6"
# App to be installed
appNameForInstall="$7"

############ Variables for Jamf Pro Parameters - End ###################
# Full fwlink URL
fullURL="https://go.microsoft.com/fwlink/?linkid=$linkID"
# jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon Download
helperIconDownload="/System/Library/CoreServices/Install in Progress.app/Contents/Resources/Installer.icns"
# Helper title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="          ${appNameForInstall}          "
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Get the icons for the complete helper
curl -s --url https://images.bauermedia.co.uk/JamfPro/Office365Icon.png > /var/tmp/Office365Icon.png

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appNameForInstall}...

** Download time will depend on the speed of your current internet connection **" -alignDescription natural &
}

function jamfHelperInstallComplete ()
{
# Install complete helper
"$jamfHelper" -windowType utility -icon "$helperIconComplete" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${appNameForInstall} Installation Complete ✅" -alignDescription natural -timeout 10 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${appNameForInstall} Installation Failed ⚠️

Please reboot your Mac and install ${appNameForInstall} from Self Service again." -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function failureKillHelper ()
{
# Kill the download helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Show the failure helper
jamfHelperFailed
}

function cleanUp ()
{
# Remove the temporary working directory when done
/bin/rm -Rf "$tempDirectory"
echo "Deleting temporary directory '$tempDirectory' and its contents"
if [[ ! -d "$tempDirectory" ]]; then
    echo "Temporary directory deleted"
else
    echo "Failed to delete the temporary directory"
fi
# Remove temp icon
/bin/rm -f "/var/tmp/Office365Icon.png" >/dev/null 2>&1
}

########################################################################
#                         Script starts here                           #
########################################################################

# Create a temporary working directory
echo "Creating temporary directory for the download"
tempDirectory=$(/usr/bin/mktemp -d "/private/tmp/MicrosoftAppDownload.XXXXXX")
# Jamf Helper for download in progress
jamfHelperDownloadInProgress
# Download the installer package and name using the value found in parameter 6
echo "Downloading package $pkgName.pkg"
/usr/bin/curl --location --silent "$fullURL" -o "${tempDirectory}/${pkgName}.pkg"
# Check if the download completed
commandResult="$?"
if [[ "$commandResult" -ne "0" ]]; then
    echo "Failed to download the package, exiting..."
    # kill previous helper and show a failure helper
    failureKillHelper
    # Remove temp content
    cleanUp
    exit 1
fi
# Checksum the download
downloadChecksum=$(/usr/bin/shasum -a 256 "${tempDirectory}/${pkgName}.pkg" | /usr/bin/awk '{ print $1 }')
echo "Checksum for downloaded package: $downloadChecksum"
# Install the package if checksum validates
if [ "$sha256Checksum" = "$downloadChecksum" ] || [ "$sha256Checksum" = "" ]; then
	echo "Checksum verified. Installing package $pkgName.pkg"
	/usr/sbin/installer -pkg "${tempDirectory}/${pkgName}.pkg" -target /
    commandResult="$?"
    if [[ "$commandResult" -ne "0" ]]; then
        echo "Failed to install the package"
        # kill previous helper and show a failure helper
        # Remove temp content
        cleanUp
        exit 1
    else
        # Kill the download helper
        killall -13 "jamfHelper" >/dev/null 2>&1
    fi
else
	echo "Checksum failed. Recalculate the SHA 256 checksum and try again. Or download may not be valid."
    # kill previous helper and show a failure helper
    failureKillHelper
    # Remove temp content
    cleanUp
	exit 1
fi
sleep 2
# Define helper complete icon. This is defined later so that the app icon can be used post install
helperIconComplete="$8" # defined as a parameter in Jamf Pro
if [[ ! -e "$helperIconComplete" ]]; then
    helperIconComplete="/System/Library/CoreServices/Installer.app/Contents/PlugIns/Summary.bundle/Contents/Resources/Success.pdf"
fi
# Install success helper
jamfHelperInstallComplete
# Remove temp content
cleanUp
exit 0