#!/bin/zsh

########################################################################
#              Download and Install Microsoft Applications             #
################### written by Phil Walker Jan 2021 ####################
########################################################################
# Edit Feb 2021 for download and install progress output to DEPNotify

# Credit to Written William Smith (Professional Services Engineer @Jamf bill@talkingmoose.net
# https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a

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
# Package Name
pkgName="$5"
# Friendly name for DEPNotify
appName="$6"
# Determinate level for DEPNotify
determinateLevel="$7"
############ Variables for Jamf Pro Parameters - End ###################
# Full fwlink URL
fullURL="https://go.microsoft.com/fwlink/?linkid=$linkID"
# DEPNotify process
depNotify=$(pgrep "DEPNotify")
# DEPNotify log
logFile="/var/tmp/depnotify.log"

########################################################################
#                         Script starts here                           #
########################################################################

# Create a temporary working directory
/bin/echo "Creating temporary directory for the download"
tempDirectory=$(/usr/bin/mktemp -d "/private/tmp/MicrosoftAppDownload.XXXXXX")
# Show download and install info in DEPNotify if the Mac is being provisioned
if [[ "$depNotify" != "" ]]; then
    /bin/echo "Mac is being provisioned, progress will be displayed in DEPNotify"
    # Set determinate to Manual - Used to pause the status bar during the download/install process
    /bin/echo "Command: DeterminateManual: ${determinateLevel}" >> "$logFile"
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    /bin/echo "Status: Downloading ${appName}..." >> "$logFile"
    /bin/sleep 1
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    # Download the installer package and name using the value found in parameter 5
    /bin/echo "Downloading ${appName} package..."
    #/usr/bin/curl -L -# "$fullURL" -o "${tempDirectory}/${pkgName}.pkg" 2>&1 | while IFS= read -r -n1 char; do # bash version
    /usr/bin/curl -L -# "$fullURL" -o "${tempDirectory}/${pkgName}.pkg" 2>&1 | while IFS= read -u 0 -sk 1 char; do
        [[ $char =~ [0-9] ]] && keep=1;
        [[ $char == % ]] && /bin/echo "Status: Downloading ${appName}... ${progress}%" >> "$logFile" && progress="" && keep=0;
        [[ $keep == 1 ]] && progress="$progress$char";
    done
    # Check if the download completed
    if [[ -e "${tempDirectory}/${pkgName}.pkg" ]]; then
        /bin/echo "Successfully downloaded ${appName} package"
    else
        /bin/echo "Failed to download the package, exiting..."
        exit 1
    fi
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    /bin/echo "Status: Installing ${appName}..." >> "$logFile"
    /bin/sleep 1
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    # Run installer in verboseR mode to give installer percentage and then output to DEPNotify
    /bin/echo "Installing ${appName}..."
	#/usr/sbin/installer -pkg "${tempDirectory}/${pkgName}.pkg" -target / -verboseR 2>&1 | while read -r -n1 char; do # bash version
    /usr/sbin/installer -pkg "${tempDirectory}/${pkgName}.pkg" -target / -verboseR 2>&1 | while read -u 0 -sk 1 char; do
        [[ $char == % ]] && keep=1;
        [[ $char =~ [0-9] ]] && [[ $keep == 1 ]] && progress="$progress$char";
        [[ $char == . ]] && [[ $keep == 1 ]] && /bin/echo "Status: Installing ${appName}... ${progress}%" >> "$logFile" && progress="" && keep=0;
    done
    /bin/echo "${appName} install complete"
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    /bin/echo "Status: ${appName} install complete" >> "$logFile"
    /bin/sleep 1
    /bin/echo "Command: DeterminateManualStep: 1" >> "$logFile"
    # Set determinate back to auto
    /bin/echo "Command: Determinate: ${determinateLevel}" >> "$logFile"
else
	/bin/echo "Mac not being provisioned, install silently"
    # Download the installer package and name using the value found in parameter 5
    /bin/echo "Downloading ${appName} package..."
    /usr/bin/curl --location --silent "$fullURL" -o "${tempDirectory}/${pkgName}.pkg"
    # Check if the download completed
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        /bin/echo "Successfully downloaded ${appName} package"
    else
        /bin/echo "Failed to download the package, exiting..."
        exit 1
    fi
	/bin/echo "Installing ${appName}..."
	/usr/sbin/installer -pkg "${tempDirectory}/${pkgName}.pkg" -target /
fi
# Remove the temporary working directory when done
/bin/rm -Rf "$tempDirectory"
/bin/echo "Deleting temporary directory ${tempDirectory} and its contents"
if [[ ! -d "$tempDirectory" ]]; then
    /bin/echo "Temporary directory deleted"
else
    /bin/echo "Failed to delete the temporary directory"
fi
exit 0