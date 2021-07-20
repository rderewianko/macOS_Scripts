#!/bin/zsh

########################################################################
#          Download and Install Microsoft Office 365 for Mac           #
################### written by Phil Walker Jan 2021 ####################
########################################################################
# Edit Feb 2021 for download and install progress output to DEPNotify
# Edit July 2021 for Office 365 for Mac download and install only

# Credit to Written William Smith (Professional Services Engineer @Jamf bill@talkingmoose.net
# https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a

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
# Friendly name for DEPNotify
appName="$5"
# Path for installed application e.g /Applications/Microsoft Outlook.app (For Office only check for Outlook)
installedApp="$6"
# Determinate level for DEPNotify
determinateLevel="$7"
############ Variables for Jamf Pro Parameters - End ###################
# Full fwlink URL
fullURL="https://go.microsoft.com/fwlink/?linkid=$linkID"
# Target package
targetPKG=$(/usr/bin/curl --head --location --silent "$fullURL" | grep -i "location" | grep -i ".pkg" | awk -F '/' '{print $NF}' | tr -d '\r')
#targetPKG=$(/usr/bin/curl --head --location --silent "$fullURL" | sed '/^HTTP\/1.1 3[0-9][0-9]/,/^\r$/d' | grep "Content-Disposition" | awk -F '[=]' '{print $2}' | tr -d '\r') # Alt method
# Target package size - Some apps return multiple headers, find the Content-Length that isn't 0
targetPKGSizeCheck=$(/usr/bin/curl --head --location --silent "$fullURL" | grep -i "Content-Length" | grep -v "Access-Control-Expose-Headers" | sed 's/[^0-9]//g')
for pkgSize in ${(f)targetPKGSizeCheck}; do
    if [[ "$pkgSize" -ne "0" ]]; then
        targetPKGSize="$pkgSize"
    fi
done
# DEPNotify process
depNotify=$(/usr/bin/pgrep "DEPNotify")
# DEPNotify log
logFile="/var/tmp/depnotify.log"

########################################################################
#                            Functions                                 #
########################################################################

function cleanUp ()
{
# Remove the temporary working directory when done
/bin/rm -Rf "$tempDirectory"
/bin/echo "Deleting temporary directory ${tempDirectory} and its contents"
if [[ ! -d "$tempDirectory" ]]; then
    /bin/echo "Temporary directory deleted"
else
    /bin/echo "Failed to delete the temporary directory"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Create a temporary working directory
/bin/echo "Creating temporary directory for the download"
tempDirectory=$(/usr/bin/mktemp -d "/private/tmp/MicrosoftAppDownload.XXXXXX")
echo "Target package: $targetPKG"
echo "Target package size: $targetPKGSize bytes"
# Show download and install info in DEPNotify if the Mac is being provisioned
if [[ "$depNotify" != "" ]]; then
    /bin/echo "Mac is being provisioned, progress will be displayed in DEPNotify"
    # Set determinate to Manual - Used to pause the status bar during the download/install process
    /bin/echo "Command: DeterminateManual: ${determinateLevel}" >> "$logFile"
    /bin/echo "Status: Downloading ${appName}..." >> "$logFile"
    /bin/sleep 1
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    # Download the installer package
    /bin/echo "Downloading ${appName} package..."
    #/usr/bin/curl -L -# "$fullURL" -o "${tempDirectory}/${targetPKG}" 2>&1 | while IFS= read -r -n1 char; do # bash version
    /usr/bin/curl -L -# "$fullURL" -o "${tempDirectory}/${targetPKG}" 2>&1 | while IFS= read -u 0 -sk 1 char; do
        [[ $char =~ [0-9] ]] && keep=1;
        [[ $char == % ]] && /bin/echo "Status: Downloading ${appName}... ${progress}%" >> "$logFile" && progress="" && keep=0;
        [[ $keep == 1 ]] && progress="$progress$char";
    done
    # Check if the download completed
    downloadedPKG=$(stat -f%z "${tempDirectory}/${targetPKG}")
    echo "Downloaded package size: $downloadedPKG bytes"
    if [[ "$targetPKGSize" -eq "$downloadedPKG" ]]; then
        /bin/echo "Target package and downloaded package file sizes match"
        /bin/echo "${appName} download complete"
    else
        /bin/echo "${appName} download failed!"
        /bin/echo "Status: ${appName} download failed!" >> "$logFile"
        /bin/sleep 2
        /bin/echo "Status: Attempting to download and install ${appName} again..." >> "$logFile"
        /bin/sleep 2
        # Call policy to install Office 365 for Mac package
        /usr/local/jamf/bin/jamf policy -event "install_officeformac_package"
        # Set determinate back to auto
        /bin/echo "Command: Determinate: ${determinateLevel}" >> "$logFile"
        # Remove temp content
        cleanUp
        exit 0
    fi
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    /bin/echo "Status: Installing ${appName}..." >> "$logFile"
    /bin/sleep 1
    # Run installer in verboseR mode to give installer percentage and then output to DEPNotify
    /bin/echo "Installing ${appName}..."
	#/usr/sbin/installer -pkg "${tempDirectory}/${targetPKG}" -target / -verboseR 2>&1 | while read -r -n1 char; do # bash version
    /usr/sbin/installer -pkg "${tempDirectory}/${targetPKG}" -target / -verboseR 2>&1 | while read -u 0 -sk 1 char; do
        [[ $char == % ]] && keep=1;
        [[ $char =~ [0-9] ]] && [[ $keep == 1 ]] && progress="$progress$char";
        [[ $char == . ]] && [[ $keep == 1 ]] && /bin/echo "Status: Installing ${appName}... ${progress}%" >> "$logFile" && progress="" && keep=0;
    done
    # Check the app installed successfully (Unable to use exit code due to method used to output to DEPNotify)
    # For Office for Mac we check for 1 app only e.g Outlook
    if [[ -d "$installedApp" ]]; then
        /bin/echo "${appName} install complete"
        /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
        /bin/echo "Status: ${appName} install complete" >> "$logFile"
        /bin/sleep 1
        # Set determinate back to auto
        /bin/echo "Command: Determinate: ${determinateLevel}" >> "$logFile"
    else
        /bin/echo "${appName} install failed!"
        /bin/echo "Status: ${appName} install failed!" >> "$logFile"
        /bin/sleep 2
        /bin/echo "Status: ${appName} is available for install in Self Service" >> "$logFile"
        /bin/sleep 2
        # Set determinate back to auto
        /bin/echo "Command: Determinate: ${determinateLevel}" >> "$logFile"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
	/bin/echo "Mac not being provisioned, install silently"
    # Download the installer package
    /bin/echo "Downloading ${appName}..."
    /usr/bin/curl --location --silent "$fullURL" -o "${tempDirectory}/${targetPKG}"
    # Check if the download completed
    downloadedPKG=$(stat -f%z "${tempDirectory}/${targetPKG}")
    echo "Downloaded package size: ${downloadedPKG} bytes"
    if [[ "$targetPKGSize" -eq "$downloadedPKG" ]]; then
        /bin/echo "Target package and downloaded package file sizes match"
        /bin/echo "${appName} download complete"
    else
        /bin/echo "${appName} download failed!"
        /bin/echo "Attempting to download and install ${appName} again..."
        # Call policy to install Office 365 for Mac package
        /usr/local/jamf/bin/jamf policy -event "install_officeformac_package"
        # Remove temp content
        cleanUp
        exit 0
    fi
	/bin/echo "Installing ${appName}..."
	/usr/sbin/installer -pkg "${tempDirectory}/${targetPKG}" -target /
    # Check the app installed successfully
    commandResult="$?"
    if [[ "$commandResult" -ne "0" ]]; then
        /bin/echo "${appName} install failed!"
        # Remove temp content
        cleanUp
        exit 1
    fi
fi
# Remove temp content
cleanUp
exit 0