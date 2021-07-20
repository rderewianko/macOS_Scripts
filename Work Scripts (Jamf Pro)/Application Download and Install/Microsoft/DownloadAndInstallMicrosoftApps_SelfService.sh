#!/bin/zsh

########################################################################
#              Download and Install Microsoft Applications             #
#                     (Self Service only version)                      #
################### written by Phil Walker Jan 2021 ####################
########################################################################

# Credit to William Smith (Professional Services Engineer @Jamf bill@talkingmoose.net
# https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a
# Edited by Phil Walker Feb 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Microsoft fwlink (permalink) product ID e.g. "2009112" for Office 365 Business Pro
linkID="$4"
# 525133 - Office 2019 for Mac SKUless download (aka Office 365)
# 2009112 - Office 2019 for Mac BusinessPro SKUless download (aka Office 365 with Teams)
# 871743 - Office 2016 for Mac SKUless download
# 830196 - AutoUpdate download
# 2093504 - Edge (Stable)
# 525135 - Excel 2019 SKUless download
# 871750 - Excel 2016 SKUless download
# 869655 - InTune Company Portal download
# 823060 - OneDrive download
# 820886 - OneNote download
# 525137 - Outlook 2019 SKUless download
# 871753 - Outlook 2016 SKUless download
# 525136 - PowerPoint 2019 SKUless download
# 871751 - PowerPoint 2016 SKUless download
# 868963 - Remote Desktop
# 800050 - SharePoint Plugin download
# 832978 - Skype for Business download
# 869428 - Teams
# 525134 - Word 2019 SKUless download
# 871748 - Word 2016 SKUless download
# App to be installed
appName="$5"

############ Variables for Jamf Pro Parameters - End ###################
# Full fwlink URL
fullURL="https://go.microsoft.com/fwlink/?linkid=$linkID"
# Target package
targetPKG=$(/usr/bin/curl --head --location --silent "$fullURL" | grep -i "location" | grep -i ".pkg" | awk -F '/' '{print $NF}' | tr -d '\r')
# Target package size - Some apps return multiple headers, find the Content-Length that isn't 0
targetPKGSizeCheck=$(/usr/bin/curl --head --location --silent "$fullURL" | grep -i "Content-Length" | grep -v "Access-Control-Expose-Headers" | sed 's/[^0-9]//g')
#targetPKGSize=$(/usr/bin/curl --head --location --silent "$fullURL" | sed '/^HTTP\/1.1 3[0-9][0-9]/,/^\r$/d' | grep "Content-Length" | sed 's/[^0-9]//g') # works on Big Sur but not Catalina
for pkgSize in ${(f)targetPKGSizeCheck}; do
    if [[ "$pkgSize" -ne "0" ]]; then
        targetPKGSize="$pkgSize"
    fi
done
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
# Get the icons for the complete helper
curl -s --url https://images.bauermedia.co.uk/JamfPro/Office365Icon.png > /var/tmp/Office365Icon.png

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

Please reboot your Mac and install ${appName} from Self Service again." -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
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
echo "Target package: $targetPKG"
echo "Target package size: $targetPKGSize bytes"
# Jamf Helper for download in progress
jamfHelperDownloadInProgress
# Download the installer package
echo "Downloading ${appName} package..."
/usr/bin/curl --location --silent "$fullURL" -o "${tempDirectory}/${targetPKG}"
# Check if the download completed
downloadedPKG=$(stat -f%z "${tempDirectory}/${targetPKG}")
echo "Downloaded package size: ${downloadedPKG} bytes"
if [[ "$targetPKGSize" -eq "$downloadedPKG" ]]; then
    echo "Target package and downloaded package file sizes match"
    echo "${appName} download complete"
else
    echo "Failed to download the package, exiting..."
    # kill previous helper and show a failure helper
    failureKillHelper
    # Remove temp content
    cleanUp
    exit 1
fi
/bin/echo "Installing ${appName}..."
/usr/sbin/installer -pkg "${tempDirectory}/${targetPKG}" -target /
commandResult="$?"
if [[ "$commandResult" -eq "0" ]]; then
    # Kill the download helper
    killall -13 "jamfHelper" &>/dev/null
else
    echo "Failed to install the package, exiting..."
    # kill previous helper and show a failure helper
    failureKillHelper
    # Remove temp content
    cleanUp
    exit 1
fi
sleep 2
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