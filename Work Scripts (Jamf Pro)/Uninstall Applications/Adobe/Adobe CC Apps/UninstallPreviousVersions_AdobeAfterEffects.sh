#!/bin/sh

########################################################################
#         Uninstall Previous Versions of Adobe After Effects CC        #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Get all user Adobe Launch Agents/Daemons PIDs
userPID=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
#path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
#App sap code
sapCode="AEFT"

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

#Kill all Adobe processes/launch agents/launch daemons
killAdobe

sleep 5

echo "Uninstalling previous verisons of Adobe After Effects..."
#Uninstall 2015
if [[ -d /Applications/Adobe\ After\ Effects\ CC\ 2015 ]]; then
    rm -rf /Applications/Adobe\ After\ Effects\ CC\ 2015 >/dev/null 2>&1
    if [[ $? == "0" ]]; then
        echo "Adobe After Effects CC 2015 uninstalled"
    fi
fi
#Uninstall 2017
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=14.0.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe After Effects CC 2017 uninstalled"
fi
rm -rf /Applications/Adobe\ After\ Effects\ CC\ 2017 >/dev/null 2>&1
#Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=15.0.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe After Effects CC 2018 uninstalled"
fi
rm -rf /Applications/Adobe\ After\ Effects\ CC\ 2018 >/dev/null 2>&1
#Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=16.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe After Effects CC 2019 uninstalled"
fi
rm -rf /Applications/Adobe\ After\ Effects\ CC\ 2019 >/dev/null 2>&1

echo "Previous versions of Adobe After Effects uninstalled"

exit 0