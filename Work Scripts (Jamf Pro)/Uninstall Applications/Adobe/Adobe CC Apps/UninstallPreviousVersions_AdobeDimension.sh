#!/bin/bash

########################################################################
#             Uninstall Previous Versions of Adobe Dimension           #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Get all user Adobe Launch Agents/Daemons PIDs
userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
#path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
#App sap code
sapCode="ESHR"

########################################################################
#                            Functions                                 #
########################################################################

function killAdobe ()
{
#Kill all user Adobe Launch Agents/Daemons
for pid in $userPIDs; do
    kill "$pid" 2>/dev/null
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

# Kill all Adobe processes/launch agents/launch daemons
killAdobe
# Wait before uninstalling
sleep 10
echo "Uninstalling previous versions of Adobe Dimension..."
#Uninstall version 1
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=1.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Dimension uninstalled"
fi
#Uninstall version 2
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=2.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Dimension uninstalled"
fi

exit 0