#!/bin/bash

########################################################################
# Stop+Unload Adobe Launch Agents/Daemons And Kill All Adobe Processes #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

#Required to avoid new app installation failures

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Get all user Adobe Launch Agents/Daemons PIDs
userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')

########################################################################
#                         Script starts here                           #
########################################################################

#Kill all user Adobe Launch Agents and Daemons
if [[ "$userPIDs" != "" ]]; then
    while IFS= read -r line; do
        kill -9 "$line" 2>/dev/null
    done <<< "$userPIDs"
fi
echo "All user Adobe Launch Agent and Daemon processes killed"

#Unload user Adobe Launch Agents
su -l "$loggedInUser" -c "/bin/launchctl unload /Library/LaunchAgents/com.adobe.* 2>/dev/null"
echo "All user Adobe Launch Agents unloaded"

#Unload Adobe Launch Daemons
/bin/launchctl unload /Library/LaunchDaemons/com.adobe.* 2>/dev/null
echo "All Adobe Launch Daemons unloaded"

pkill "obe"
sleep 5
#Close any Adobe Crash Reporter windows (e.g. Bridge)
pkill -9 "Crash Reporter"
echo "All remaining Adobe processes killed"
# Kill Safari processes - can cause install failure (Error DW046 - Conflicting processes are running)
killall -9 "Safari"

exit 0