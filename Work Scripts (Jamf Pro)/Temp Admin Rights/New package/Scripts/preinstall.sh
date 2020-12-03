#!/bin/zsh

########################################################################
#           Grant Temporary Admin Privileges - preinstall              #
####################### written by Phil Walker #########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Launch Daemon
launchDaemon="/Library/LaunchDaemons/com.bauer.tempadmin.plist"
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon
helperIcon="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
# Helper title
helperTitle="Message from Bauer IT"

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperAdminRemoved () 
{
# Show jamfHelper message to advise admin rights removed
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "Administrator Priviliges failed" \
-description "It looks like something went wrong when trying to change your account priviliges.

Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ $(launchctl list | grep "com.bauer.tempadmin") == "" ]]; then
    echo "Temp Admin Launch Daemon not currently bootstrapped"
else
    launchctl bootout system "$launchDaemon" 2>/dev/null
    sleep 2
    if [[ $(launchctl list | grep "com.bauer.tempadmin") == "" ]]; then
        echo "Temp Admin Launch Daemon booted out successfully"
    else
        echo "Temp Admin Launch Daemon still boostrapped"
    fi
fi

if [[ -f "$launchDaemon" ]]; then
    rm -f "$launchDaemon"
    if [[ ! -f "$launchDaemon" ]]; then
        echo "Temp Admin Launch Daemon deleted"
        exit 0
    fi
elif [[ ! -f "$launchDaemon" ]]; then
    echo "No previous content found"
    exit 0
else
    echo "Somthing went wrong - temporary admin rights cannot be provided"
    "$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "Administrator Priviliges failed" \
    -description "It looks like something went wrong when trying to change your account priviliges.

    Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1
    exit 1
fi
