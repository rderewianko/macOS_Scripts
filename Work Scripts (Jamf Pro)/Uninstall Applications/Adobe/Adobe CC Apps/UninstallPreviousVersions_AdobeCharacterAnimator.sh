#!/bin/bash

########################################################################
#        Uninstall Previous Versions of Adobe Character Animator       #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get all user Adobe Launch Agents/Daemons PIDs
userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
# path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
# App sap code
sapCode="CHAR"

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
# Kill all user Adobe Launch Agents/Daemons
for pid in $userPIDs; do
    kill "$pid" 2>/dev/null
done
# Unload user Adobe Launch Agents
su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"
# Unload Adobe Launch Daemons
/bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null
pkill "obe"
}

########################################################################
#                         Script starts here                           #
########################################################################

# Kill all Adobe processes/launch agents/launch daemons
killAdobe
# Wait before uninstalling
sleep 10
echo "Uninstalling previous versions of Adobe Character Animator..."
# Uninstall Preview
if [[ -d /Applications/Adobe\ Character\ Animator\ \(Preview\) ]]; then
    rm -rf /Applications/Adobe\ Character\ Animator\ \(Preview\) >/dev/null 2>&1
    if [[ $? == "0" ]]; then
        echo "Adobe Character Animator Preview uninstalled"
    fi
fi
# Uninstall Beta
"$binaryPath" --uninstall=1 --sapCode=ANMLBETA --baseVersion=1.0.5 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Character Animator Beta uninstalled"
fi
# Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=1.1.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Character Animator CC 2018 uninstalled"
fi
# Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=2.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Character Animator CC 2019 uninstalled"
fi

exit 0