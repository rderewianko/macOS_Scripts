#!/bin/bash

########################################################################
#            Uninstall Previous Versions of Adobe Audition CC          #
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
sapCode="AUDT"

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
echo "Uninstalling previous versions of Adobe Audition..."
# Uninstall 2015
if [[ -d /Applications/Adobe\ Audition\ CC\ 2015 ]]; then
    rm -rf /Applications/Adobe\ Audition\ CC\ 2015 >/dev/null 2>&1
    if [[ $? == "0" ]]; then
        echo "Adobe Audition CC 2015 uninstalled"
    fi
fi
# Uninstall 2015.3
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=9.2.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Audition 2015.3 uninstalled"
fi
# Uninstall 2017
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=10.0.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Audition 2017 uninstalled"
fi
# Uninstall 2018
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=11.0.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Audition 2018 uninstalled"
fi
# Uninstall 2019
"$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion=12.0 --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Adobe Audition 2019 uninstalled"
fi

exit 0