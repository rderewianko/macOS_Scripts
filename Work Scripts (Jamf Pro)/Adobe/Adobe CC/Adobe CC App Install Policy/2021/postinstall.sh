#!/bin/bash

########################################################################
#       Adobe CC Application Install Policy Script - Postinstall       #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Must be set to run after the package install

# Credit to John Mahlman, University of the Arts Philadelphia (jmahlman@uarts.edu) for his script
# Adobe-RUMWithProgress-jamfhelper which I used as the basis for this script

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# CC App name for helper windows e.g. Adobe Photoshop 2021
installedAppName="$4"
# CC App bundle e.g. /Applications/Adobe Photoshop 2021/Adobe Photoshop 2021.app
installedAppBundle="$5"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Adobe Remote Update Manager binary
rumBinary="/usr/local/bin/RemoteUpdateManager"
# RUM log file
logFile="/Library/Logs/Bauer/AdobeUpdates/AdobeCCUpdates_SelfService.log"
# jamfHelper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper Icon
helperIcon="/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Desktop App.app/Contents/Resources/CreativeCloudApp.icns"
# Helper Icon for update check
helperUpdateCheckIcon="/System/Library/CoreServices/Install Command Line Developer Tools.app/Contents/Resources/SoftwareUpdate.icns"
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Helper Title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="     Adobe CC Application Updates     "
# Failure Helper eading
failureHelperHeading="          ${installedAppName}          "

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
else
    # Get all user Adobe Launch Agents/Daemons PIDs
    userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
    # Kill all user Adobe Launch Agents/Daemons
    if [[ "$userPIDs" != "" ]]; then
        while IFS= read -r line; do
            kill -9 "$line" 2>/dev/null
        done <<< "$userPIDs"
    fi
    # Bootout all user Adobe Launch Agents
    launchctl bootout gui/"$loggedInUserID" /Library/LaunchAgents/com.adobe.* 2>/dev/null
    # Bootout Adobe Launch Daemons
    launchctl bootout system /Library/LaunchDaemons/com.adobe.* 2>/dev/null
    pkill -9 "obe"
    sleep 5
    # Close any Adobe Crash Reporter windows (e.g. Bridge)
    pkill -9 "Crash Reporter"
fi
}

function jamfHelperCheckUpdates ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperUpdateCheckIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${installedAppName} Installation Complete ✅

Checking for all available Adobe CC application updates..." -alignDescription natural -timeout 10 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$failureHelperHeading" -alignHeading natural \
-description "${installedAppName} Installation Failed ⚠️

Please reboot your Mac and install ${installedAppName} from Self Service again." -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function jamfHelperUpdatesToInstall ()
{
# Updates to be installed helper
updatesToInstall=$("$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "The below Adobe CC app updates will start to install in 20 seconds
    $updatesAvailable
⚠️ All Adobe CC apps will be closed automatically ⚠️" -alignDescription natural -timeout 20 &)
}

function jamfHelperInstallInProgress ()
{
# Download in progress
su - "$loggedInUser" <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Adobe\ Creative\ Cloud/Utils/Creative\ Cloud\ Desktop\ App.app/Contents/Resources/CreativeCloudApp.icns -title "Message from Bauer IT" -heading "     Adobe CC Application Updates     " -alignHeading natural -description "Adobe CC app updates downloading and installing...     

⚠️ Please do not open any Adobe CC app ⚠️ 

This process may take some time to complete" -alignDescription natural &
jamfmsg1
}

function jamfHelperNoUpdates ()
{
# No updates available helper
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "There are currently no Adobe CC application updates available" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function jamfHelperUpdatesInstalled ()
{
# Updates installed helper
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "     All updates below installed successfully ✅
    $updatesInstalled" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function installUpdates ()
{
# Install in progress Jamf Helper
jamfHelperInstallInProgress
# Install all available updates and output result to the log
"$rumBinary" --action=install > "$logFile"
# Kill install in progress helper
killall -13 "jamfHelper" >/dev/null 2>&1
sleep 2
# Read the log file to check which updates installed successfully for use in a jamf Helper window
updatesInstalled=$(sed -n '/Following Updates were successfully installed*/,/\*/p' $logFile \
    | sed 's/Following Updates were successfully installed :/*/g' | grep -v "*" \
    | sed 's/AEFT/After\ Effects/g' \
    | sed 's/FLPR/Animate/g' \
    | sed 's/AUDT/Audition/g' \
    | sed 's/KBRG/Bridge/g' \
    | sed 's/CHAR/Character\ Animator/g' \
    | sed 's/ESHR/Dimension/g' \
    | sed 's/DRWV/Dreamweaver/g' \
    | sed 's/ILST/Illustrator/g' \
    | sed 's/AICY/InCopy/g' \
    | sed 's/IDSN/InDesign/g' \
    | sed 's/LRCC/Lightroom/g' \
    | sed 's/LTRM/Lightroom\ Classic/g' \
    | sed 's/AME/Media\ Encoder/g' \
    | sed 's/PHSP/Photoshop/g' \
    | sed 's/PRLD/Prelude/g' \
    | sed 's/PPRO/Premiere\ Pro/g' \
    | sed 's/RUSH/Premiere\ Rush/g' \
    | sed 's/SPRK/XD/g' \
    | sed 's/ACR/Camera\ Raw/g' \
    | sed 's/COSY/CoreSync/g' \
    | sed 's/AdobeAcrobatDC-19.0/Acrobat\ Pro\ DC/g' \
    | sed 's/AdobeAcrobatDC-20.0/Acrobat\ Pro\ DC/g' \
    | sed 's/AdobeARMDCHelper/Acrobat\ Update\ Helper/g' \
    | sed 's/[()]//g' | sed 's/osx10-64//g' | sed 's/osx10//g' | sed 's/\// /g' \
    | grep -v "*")
echo "All updates below installed successfully"
echo "------------------------------------------"
echo "$updatesInstalled"
echo "------------------------------------------"
}

########################################################################
#                         Script starts here                           #
########################################################################

# Kill any open jamf Helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Confirm RUM is installed
if [[ ! -e "$rumBinary" ]]; then
    # RUM not installed, do nothing
    echo "Adobe Remote Update Manager not installed"
    echo "No updates can be installed at this time"
    exit 0
else
    if [[ -d "$installedAppBundle" ]]; then
        echo "Installation successful, checking for all available updates..."
        # jamf Helper for update check
        jamfHelperCheckUpdates
        # Remove previous log
        if [[ -f "$logFile" ]]; then
            rm -f "$logFile"
            if [[ -f "$logFile" ]]; then
                echo "Previous log file removal failed, info displayed in jamfHelper windows will be incorrect" 
            fi
        fi
        # Create the log directory if required
        if [[ ! -d "/Library/Logs/Bauer/AdobeUpdates" ]]; then
            mkdir -p "/Library/Logs/Bauer/AdobeUpdates"
        fi
        # Create log file
        touch "$logFile"
        {
        echo "Script started at: $(date +"%H-%M-%S (%d-%m-%Y)")"
        echo "Checking for updates..."
        echo "--------------------------------------------------"
        } >> "$logFile"
        "$rumBinary" --action=list > "$logFile"
        # Read the log file to check which updates are available for install for use in a jamf Helper window
        updatesAvailable=$(sed -n '/Following*/,/\*/p' $logFile \
            | sed 's/Following Updates are applicable on the system :/*/g'  | grep -v "*" \
            | sed 's/Following Acrobat\/\Reader updates are applicable on the system :/*/g' | grep -v "*" \
            | sed 's/AEFT/After\ Effects/g' \
            | sed 's/FLPR/Animate/g' \
            | sed 's/AUDT/Audition/g' \
            | sed 's/KBRG/Bridge/g' \
            | sed 's/CHAR/Character\ Animator/g' \
            | sed 's/ESHR/Dimension/g' \
            | sed 's/DRWV/Dreamweaver/g' \
            | sed 's/ILST/Illustrator/g' \
            | sed 's/AICY/InCopy/g' \
            | sed 's/IDSN/InDesign/g' \
            | sed 's/LRCC/Lightroom/g' \
            | sed 's/LTRM/Lightroom\ Classic/g' \
            | sed 's/AME/Media\ Encoder/g' \
            | sed 's/PHSP/Photoshop/g' \
            | sed 's/PRLD/Prelude/g' \
            | sed 's/PPRO/Premiere\ Pro/g' \
            | sed 's/RUSH/Premiere\ Rush/g' \
            | sed 's/SPRK/XD/g' \
            | sed 's/ACR/Camera Raw/g' \
            | sed 's/AdobeAcrobatDC-19.0/Acrobat\ Pro\ DC/g' \
    	    | sed 's/AdobeAcrobatDC-20.0/Acrobat\ Pro\ DC/g' \
            | sed 's/AdobeARMDCHelper/Acrobat\ Update\ Helper/g' \
            | sed 's/[()]//g' | sed 's/osx10-64//g' | sed 's/osx10//g' | sed 's/\// /g' \
            | grep -v "*")
        # Check if any updates are required
        updatesCheck=$(cat "$logFile")
        if [[ "$updatesCheck" =~ "Following" ]]; then
            echo "Updates available"
            # Updates installing helper
            jamfHelperUpdatesToInstall
            echo "Installing updates listed below"
            echo "------------------------------------------"
            echo "$updatesAvailable"
            echo "------------------------------------------"
            # Kill all open CC apps
            killAdobe
            # Install all updates
            installUpdates
            # Updates installed helper
            jamfHelperUpdatesInstalled
        else
            # jame Helper for no updates available 
            jamfHelperNoUpdates
            # No updates found so nothing to do
            echo "All applications are up to date"
        fi
    else
        # Jamf Helper to advise the user to reboot and try the install again
        jamfHelperFailed
        echo "Installation failed!"
        echo "jamf Helper displayed to advise the customer to reboot and try installing ${installedAppName} from Self Service again"
        exit 1
    fi
fi

exit 0