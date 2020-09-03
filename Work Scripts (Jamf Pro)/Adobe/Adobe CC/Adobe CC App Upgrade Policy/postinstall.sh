#!/bin/bash

########################################################################
#    Adobe Creative Cloud Application Upgrade Policy Script - Post     #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Must be set to run after the package install

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# CC App name for helper windows e.g. Adobe Photoshop 2020
installedAppName="$4"
# Package Receipt
packageReceipt="$5"
# Helper complete icon
helperIconComplete="$6"
############ Variables for Jamf Pro Parameters - End ###################

# jamfHelper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Add fall back icon if the 
if [[ ! -e "$6" ]]; then
    helperIconComplete="/System/Library/CoreServices/Installer.app/Contents/PlugIns/Summary.bundle/Contents/Resources/Success.pdf"
fi
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Helper Title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="     Upgrade to ${installedAppName}     "

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperComplete ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconComplete" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${installedAppName} has now been installed and will be added to your dock ✅" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "${installedAppName} Installation Failed ⚠️

Please open the Self Service app to try the ${installedAppName} installation again.

If you continue to have issues after that please contact the IT Service Desk" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

# Kill any open jamf Helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Check for the package receipt
if [[ "$packageReceipt" != "" ]]; then
    echo "${installedAppName} installation successful"
    # jamf helper for completion
    jamfHelperComplete
else
    echo "${installedAppName} installation failed!"
    # jamf Helper for failure
    jamfHelperFailed
    echo "jamf Helper displayed to advise the customer to install ${installedAppName} from Self Service"
    exit 1
fi

exit 0