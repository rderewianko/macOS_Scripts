#!/bin/zsh

########################################################################
#            GarageBand Sound Library - Preinstall Jamf Helper         #
#################### Written by Phil Walker Mar 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Sound Library version (Essential or Complete)
libraryVersion="$4"
# Disk space required (GB)
requiredSpace="$5"
# Custom event
customEvent="$6"
############ Variables for Jamf Pro Parameters - End ###################

# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icons
helperIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Sync.icns"
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Helper title
helperTitle="Message from Bauer Technology"
# Helper heading
helperHeading="GarageBand ${libraryVersion} Sound Library"

########################################################################
#                            Functions                                 #
########################################################################

function checkSpace ()
{
# Check if free space
freeSpace=$(/usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}')
if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
	echo "Disk space check completed: ${freeSpace%.*}GB of free space detected"
    echo "Continuing with installation..."
else
	spaceStatus="ERROR"
	echo "Disk space check completed: ${freeSpace%.*}GB of free space detected"
    echo "Insufficient disk space to complete installation!"
fi
}

function jamfHelperNoSpace ()
{
helperSpace=$(
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Not enough free space found - install cannot continue!" \
-description "Please ensure you have at least ${requiredSpace}GB of free space
Available Space : ${freeSpace}Gb

Please delete files and empty your trash to free up additional space.

If you continue to experience this issue, please contact the IT Service Desk on 0345 058 4444." -button1 "Retry" -button2 "Quit" -defaultButton 1
)
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading GarageBand ${libraryVersion} Sound Library packages..." -alignDescription natural &
}

########################################################################
#                         Script starts here                           #
########################################################################


# Check the Mac meets the space requirements
checkSpace
while ! [[  ${spaceStatus} == "OK" ]]; do
    jamfHelperNoSpace
    if [[ "$helperSpace" -eq "2" ]]; then
        echo "User clicked quit at lack of space message"
        exit 1
    fi
    sleep 5
    checkSpace
done
# Show a message via Jamf Helper that the package is being downloaded
jamfHelperDownloadInProgress
# Call the install policy
/usr/local/bin/jamf policy -event "$customEvent"
exit 0