#!/bin/bash

########################################################################
#                  Grant Temporary Admin Privileges                    #
####################### written by Phil Walker #########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Deferral Options
deferralOption1="600"
deferralOption2="3600"
deferralOption3="10800"
deferralOption4="28800"
#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Get the hostname
hostName=$(scutil --get HostName)

########################################################################
#                            Functions                                 #
########################################################################

function getRealName()
{
#Find correct format for real name of logged in user
loggedInUserUID=$(dscl . -read /Users/$loggedInUser UniqueID | awk '{print $2}')

if [[ "$loggedInUser" =~ "admin" ]];then
    userRealName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2, $3}' | sed s/,//)
else
  if [[ "$loggedInUserUID" -lt "1000" ]]; then
    userRealName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2}' | sed s/,//)
  else
    userRealName=$(dscl . -read /Users/$loggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2, $1}' | sed s/,//)
  fi
fi

}

function jamfHelperAdminPeriod ()
#Prompt the user to select the time period they which to have admin rights for
{
HELPER=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/UserIcon.icns -title "Message from Bauer IT" -heading "Admin Privileges Requested" -alignHeading left -description "Please select the time period you require admin privileges for

" -lockHUD -showDelayOptions "$deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4"  -button1 "Select"

)
}

function convertTimePeriod ()
{
#Convert the seconds chosen to human readable minutes, hours. No Seconds are calulated
local T=$timeChosen;
local H=$((T/60/60%24));
local M=$((T/60%60));
timeChosenHuman=$(printf '%s';[[ $H -eq 1 ]] && printf '%d hour' $H; [[ $H -ge 2 ]] && printf '%d hours' $H; [[ $M > 0 ]] && printf '%d minutes' $M; [[ $H > 0 || $M > 0 ]])

}

########################################################################
#                         Script starts here                           #
########################################################################

getRealName
jamfHelperAdminPeriod
timeChosen="${HELPER%?}" #Removes the 1 added to the time period chosen
convertTimePeriod

#Promote the logged in user to an admin
dseditgroup -o edit -a "$loggedInUser" -t user admin

#Add time period to LaunchDaemon
/usr/libexec/PlistBuddy -c "Set StartInterval $timeChosen" /Library/LaunchDaemons/com.bauer.tempadmin.plist

#Start the launchD to remove admin rights after the chosen period has elapsed
launchctl load /Library/LaunchDaemons/com.bauer.tempadmin.plist
launchctl start /Library/LaunchDaemons/com.bauer.tempadmin.plist

#Get a list of users who are in the admin group
adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

#Check if the logged in user is in the admin group and show jamfHelper message
if [[ "$adminUsers" =~ "$loggedInUser" ]]; then
  echo "$loggedInUser is now an admin"
  #Kill bitbar to read to hostname
  killall BitBarDistro

#Show jamfHelper message to advise admin rights given and how long the privileges will be in place for
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "🔓 Administrator Privileges Granted" -description "$userRealName now has admin rights on $hostName for $timeChosenHuman

After $timeChosenHuman, admin privileges will be automatically removed.

During the $timeChosenHuman of elevated privileges please remember....

    #1) All activity on your Bauer Media owned Mac is monitored.
    #2) Think before you approve installs or updates
    #3) With great power comes great responsibility." -button1 "Ok" -defaultButton 1

exit 0

else
  echo "Something went wrong - $loggedInUser is not an admin"
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Administrator Priviliges failed" -description "It looks like something went wrong when trying to change your account priviliges.

  Please contact the IT Service Desk for assistance" -button1 "Ok" -defaultButton 1

exit 1
fi
