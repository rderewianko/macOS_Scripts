#!/bin/sh

########################################################################
#              Uninstall Previous Versions of Adobe Animate            #
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
sapCode="FLPR"

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

echo "Uninstalling previous versions of Adobe Animate..."
#Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=18.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Animate 2018 uninstalled"
fi

#Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=19.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Animate 2019 uninstalled"
fi

echo "Previous versions of Adobe Animate uninstalled"

exit 0