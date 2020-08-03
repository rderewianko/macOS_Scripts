#!/bin/bash

########################################################################
#           Uninstall Previous Versions of Adobe Photoshop CC          #
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
sapCode="PHSP"

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
# Kill all user Adobe Launch Agents/Daemons
for pid in $userPIDs; do
    kill -9 "$pid" 2>/dev/null
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
echo "Uninstalling previous verisons of Adobe Photoshop CC..."
# Uninstall 2017
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=18.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Photoshop CC 2017 uninstalled"
fi
rm -rf "/Applications/Adobe Photoshop CC 2017" >/dev/null 2>&1
# Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=19.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Photoshop CC 2018 uninstalled"
fi
rm -rf "/Applications/Adobe Photoshop CC 2018" >/dev/null 2>&1
# Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=20.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Photoshop CC 2019 uninstalled"
fi
rm -rf "/Applications/Adobe Photoshop CC 2019" >/dev/null 2>&1

exit 0