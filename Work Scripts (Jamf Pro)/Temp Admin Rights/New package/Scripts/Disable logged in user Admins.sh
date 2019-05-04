#!/bin/bash

#######################################################################
#                 Revoke Temporary Admin Privileges                   #
###################### written by Phil Walker #########################
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Get the logged in user's real name
RealName=$(dscl . -read /Users/$LoggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2, $1}' | sed s/,//)

#Get the hostname
hostName=$(scutil --get HostName)

#Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

########################################################################
#                            Functions                                 #
########################################################################

function removeTempAdminRights() {
#Loop through each account found, excludes root and any account with admin in the name - this stops casadmin, admin and any ADadmin accounts from being removed from the admin group
for user in $adminUsers
do
    if [[ "$user" != "root" && "$user" != "admin" && "$user" != "casadmin" ]];
    then
        dseditgroup -o edit -d $user -t user admin
        if [ $? = 0 ]; then echo "Removed user $user from admin group"; fi
    else
        echo "Admin user $user left alone"
    fi
done >> /usr/local/bin/RemoveAdmin.txt
}

function jamfHelperAdminRemoved() {

#Show jamfHelper message to advise admin rights removed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "🔓 Administrator Privileges Revoked" -description "$RealName's admin rights on $hostName have now been revoked" -button1 "Ok" -defaultButton 1
#Kill bitbar to read to new user rights when holding alt key
killall BitBarDistro

}

function removeLDAndScript() {
if [ -f /usr/local/bin/removeadmin.sh ]; then
  rm /usr/local/bin/removeadmin.sh
  echo "removeadmin script deleted"
fi
#Stop and unload the LaunchDaemons
if [ -f /Library/LaunchDaemons/com.bauer.tempadmin.plist ]; then
  launchctl stop /Library/LaunchDaemons/com.bauer.tempadmin.plist
  echo "LaunchDaemon stopped"
fi
if [ -f /Library/LaunchDaemons/com.bauer.tempadmin.plist ]; then
  launchctl unload /Library/LaunchDaemons/com.bauer.tempadmin.plist
  echo "LaunchDaemon unloaded"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

removeTempAdminRights
jamfHelperAdminRemoved
removeLDAndScript

exit 0
