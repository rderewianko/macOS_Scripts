#!/bin/sh

########################################################################
#                    Uninstall Adobe InCopy CC 2017                    #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
#App sap code
sapCode="AICY"
#App version
appVersion="12.0.0"

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
#Kill all user Adobe Launch Agents/Daemons
for pid in $userPID
    do
        kill $pid 2>/dev/null
done

#Unload user Adobe Launch Agents
su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"

#Unload Adobe Launch Daemons
/bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null

pkill "obe"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d /Applications/Adobe\ InCopy\ CC\ 2017 ]]; then

    echo "Adobe InCopy CC 2017 found"

    #Kill all Adobe processes/launch agents/launch daemons
    killAdobe

    sleep 5

    echo "Uninstalling Adobe InCopy CC 2017..."

    "$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$appVersion" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1

    if [[ $? == "0" ]]; then
        rm -rf /Applications/Adobe\ InCopy\ CC\ 2017 >/dev/null 2>&1
        echo "InCopy 2017 uninstalled successfully"
    else
        echo "Failed to uninstall InCopy CC 2017"
        exit 1
    fi

else

    echo "Adobe InCopy CC 2017 not found, nothing to do"
fi

exit 0