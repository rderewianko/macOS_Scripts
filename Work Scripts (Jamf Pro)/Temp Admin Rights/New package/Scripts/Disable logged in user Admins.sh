#!/bin/zsh

#######################################################################
#                 Revoke Temporary Admin Privileges                   #
###################### written by Phil Walker #########################
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the hostname
hostName=$(scutil --get HostName)
# Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)
# Launch Daemon
launchDaemon="/Library/LaunchDaemons/com.bauer.tempadmin.plist"
# Script
removalScript="/usr/local/bin/removeadmin.sh"
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon
helperIcon="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
# Helper title
helperTitle="Message from Bauer IT"
# Log file
logFile="/Library/Logs/Bauer/TempAdmin/TempAdmin.log"
# Date and time
datetime=$(date +%d-%m-%Y\ %T)

########################################################################
#                            Functions                                 #
########################################################################

function getRealName ()
{
# Find correct format for real name of logged in user
loggedInUserUID=$(dscl . -read /Users/"$loggedInUser" UniqueID | awk '{print $2}')
if [[ "$loggedInUser" =~ "admin" ]]; then
    userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2, $3}' | sed s/,//)
else
    if [[ "$loggedInUserUID" -lt "1000" ]]; then
        userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2}' | sed s/,//)
    else
        userRealName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2, $1}' | sed s/,//)
    fi
fi
}

function removeTempAdminRights () 
{
# Loop through each account found and remove from the admin group (excluding root, admin, casadmin and jamfcloudadmin).
for user in ${(z)adminUsers}; do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "casadmin" && "$user" != "jamfcloudadmin" ]]; then
        dseditgroup -o edit -d "$user" -t user admin
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "${datetime}: Removed user $user from the admin group" >> "$logFile"
        fi
    else
        echo "${datetime}: Admin user $user left alone"
    fi
done
}

function jamfHelperAdminRemoved () 
{
# Show jamfHelper message to advise admin rights removed
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "🔓 Administrator Privileges Revoked" \
-description "$userRealName's admin rights on $hostName have now been revoked" -button1 "Ok" -defaultButton 1
# Kill bitbar to read new user rights when holding alt key
killall BitBarDistro
}

function removeLDAndScript () 
{
# Remove this script
if [[ -f "$removalScript" ]]; then
    rm -f "$removalScript"
    if [[ ! -f "$removalScript" ]]; then
        echo "Admin rights removal script deleted"
    else
        echo "Failed to delete the admin rights removal script, manual clean-up required"
    fi
fi
# Bootout the Launch Daemon
if [[ -f "$launchDaemon" ]]; then
    launchctl bootout system "$launchDaemon"
    echo "Launch Daemon booted out"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, remove temp admin and display no helper"
    # Remove temp admin rights
    removeTempAdminRights
    # Remove the content
    removeLDAndScript
else
    # Get the users real name for helper windows
    getRealName
    # Remove temp admin rights
    removeTempAdminRights
    # Display a helper window to advise that admin has been removed
    jamfHelperAdminRemoved
    # Remove the content
    removeLDAndScript
fi
exit 0