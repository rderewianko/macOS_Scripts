#!/bin/bash

########################################################################
#     Install All Adobe CC Application Updates Self Service Policy     #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

# Credit to John Mahlman, University of the Arts Philadelphia (jmahlman@uarts.edu) for his script
# Adobe-RUMWithProgress-jamfhelper which I used as the basis for this script

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Kill all user Adobe Launch Agents/Daemons
userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
# Adobe Remote Update Manager binary
rumBinary="/usr/local/bin/RemoteUpdateManager"
# RUM log file
rumLog="/var/tmp/SelfServiceAdobeCCUpdates.log"
# jamfHelper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper Icon
helperIcon="/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Desktop App.app/Contents/Resources/CreativeCloudApp.icns"
# Helper Title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="     Adobe CC Application Updates     "

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
#Kill all user Adobe Launch Agents/Daemons
for pid in $userPIDs; do
    kill -9 "$pid" 2>/dev/null
done
# Unload user Adobe Launch Agents
su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"
# Unload Adobe Launch Daemons
/bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null
pkill "obe"
sleep 5
# Close any Adobe Crash Reporter windows (e.g. Bridge)
pkill "Crash Reporter"
}

function jamfHelperUpdatesAvailable ()
{
# Updates available helper
installHelper=$("$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "The below Adobe CC app updates are available
    $updatesAvailable
⚠️ All Adobe CC apps will be closed automatically ⚠️" -alignDescription natural -button1 "Install" -button2 "Cancel")
}

function jamfHelperInstallInProgress ()
{
#Download in progress
su - "$loggedInUser" <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/Utilities/Adobe\ Creative\ Cloud/Utils/Creative\ Cloud\ Desktop\ App.app/Contents/Resources/CreativeCloudApp.icns -title "Message from Bauer IT" -heading "     Adobe CC Application Updates     " -alignHeading natural -description "Adobe CC app updates downloading and installing...     

⚠️ Please do not open any Adobe CC app ⚠️ 

This process may take some time to complete" -alignDescription natural &
jamfmsg1
}

function jamfHelperUpdatesInstalled ()
{
# Updates installed helper
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "     All updates below installed successfully ✅
    $updatesInstalled" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function jamfHelperNoUpdates ()
{
# No updates available helper
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "Message from Bauer IT" -heading "$helperHeading" -alignHeading natural \
-description "There are currently no Adobe CC application updates available" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function installUpdates ()
{
# Install in progress Jamf Helper
jamfHelperInstallInProgress
# Install all available updates and output result to the log
$rumBinary --action=install > $rumLog
# Kill install in progress helper
pkill "jamfHelper"
sleep 2
# Read the log file to check which updates installed successfully for use in a jamf Helper window
updatesInstalled=$(sed -n '/Following Updates were successfully installed*/,/\*/p' $rumLog \
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

# Confirm RUM is installed
if [ ! -e $rumBinary ]; then
    # RUM not installed, do nothing
    echo "Adobe Remote Update Manager not installed"
    echo "No updates can be installed at this time"
    exit 0
else
    # Remove previous log
    if [[ -f $rumLog ]]; then
        rm -f $rumLog
        if [[ -f $rumLog ]]; then
            echo "Previous log file removal failed, info displayed in jamfHelper windows will be incorrect" 
        fi
    fi
    # Create log file, check for available updates and output results to the log
    touch $rumLog
    $rumBinary --action=list > $rumLog
    # Read the log file to check which updates are available for install for use in a jamf Helper window
    updatesAvailable=$(sed -n '/Following*/,/\*/p' $rumLog \
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
    updatesCheck=$(cat $rumLog)
    if [[ "$updatesCheck" =~ "Following" ]]; then
        echo "Updates available"
        # Updates available helper
        jamfHelperUpdatesAvailable
        # Confirm user choice
        if [[ "$installHelper" == "0" ]]; then
            echo "$loggedInUser selected install"
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
        elif [ "$installHelper" == "2" ]; then
            echo "User selected cancel, no updates will be installed"
            exit 0
        fi
    else
        # No updates found so nothing to do
        echo "All applications are up to date"
        # No updates available helper
        jamfHelperNoUpdates
    fi
fi

exit 0