#!/bin/sh

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
userPID=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')

########################################################################
#                         Script starts here                           #
########################################################################

#Kill all user Adobe Launch Agents and Daemons
for pid in $userPID
    do
        kill $pid 2>/dev/null
done
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
pkill "Crash Reporter"
echo "All remaining Adobe processes killed"

exit 0