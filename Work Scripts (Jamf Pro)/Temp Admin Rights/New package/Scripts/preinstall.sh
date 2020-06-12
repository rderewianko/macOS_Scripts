#!/bin/bash

########################################################################
#                  Grant Temporary Admin Privileges                    #
####################### written by Phil Walker #########################
########################################################################

# preinstall

########################################################################
#                            Variables                                 #
########################################################################

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
    echo "Temp Admin Launch Daemon not currently loaded"
else
    launchctl stop /Library/LaunchDaemons/com.bauer.tempadmin.plist 2>/dev/null
    launchctl unload /Library/LaunchDaemons/com.bauer.tempadmin.plist 2>/dev/null
    sleep 2
    if [[ $(launchctl list | grep "com.bauer.tempadmin") == "" ]]; then
        echo "Temp Admin Launch Daemon stopped and unloaded successfully"
    else
        echo "Temp Admin Launch Daemon still loaded"
    fi
fi

if [[ -f /Library/LaunchDaemons/com.bauer.tempadmin.plist ]]; then
    rm -f /Library/LaunchDaemons/com.bauer.tempadmin.plist
    if [[ ! -f /Library/LaunchDaemons/com.bauer.tempadmin.plist ]]; then
        echo "Temp Admin Launch Daemon deleted"
        exit 0
    fi
elif [[ ! -f /Library/LaunchDaemons/com.bauer.tempadmin.plist ]]; then
    echo "No previous content found"
    exit 0
else
    echo "Somthing went wrong - temporary admin rights cannot be provided"
    "$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "Administrator Priviliges failed" \
    -description "It looks like something went wrong when trying to change your account priviliges.

    Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1
    exit 1
fi
