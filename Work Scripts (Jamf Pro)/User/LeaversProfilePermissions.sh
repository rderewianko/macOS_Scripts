#!/bin/bash

#########################################################################
################## Leaver's Profile Permissions #########################
############## written by Phil Walker September 2017 ####################
#########################################################################

#########################
####### Variables #######
#########################

#Get the logged in user
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
echo "Current user is $LoggedInUser"

# Create temp txt file populated with leaver's username

ProfName="/tmp/ProfName.txt"

#########################
####### Functions #######
#########################

# Prompt for user to enter leavers username

function userName ()
{
username=$(su - $LoggedInUser -c /usr/bin/osascript <<EndUserName
tell application "System Events"
    activate
    set the_results to (display dialog ("Enter leaver's user logon name") with title ("Leaver's Data") buttons {"Cancel", "Continue"} default button "Continue" default answer "")
    set BUTTON_Returned to button returned of the_results
    set wks to text returned of the_results
end tell
EndUserName
)
echo "User Profile Name is : $username"
}

# Get Remote Mac asset number or IP address

function getRemoteMac ()
{
remotemac=$(su - $LoggedInUser -c /usr/bin/osascript <<EndRemoteMac
tell application "System Events"
    activate
    set the_results to (display dialog ("Enter the asset number or IP address of the remote Mac") with title ("Mac Leavers Data") buttons {"Cancel", "Continue"} default button "Continue" default answer "")
    set BUTTON_Returned to button returned of the_results
    set wks to text returned of the_results
end tell
EndRemoteMac
)
echo "Remote Mac is : $remotemac"
}

# Display dialogue to display username of leaver and remote Mac asset number or IP address entered by user

function changePermissionsCheck() {

  osascript <<EOT

set theAlertText to "Warning!"
set theAlertMessage to "You're about to change the permissions for $ProfTarg's profile on $remotemac. Would you like to continue?"
display alert theAlertText message theAlertMessage as critical buttons {"Don't Continue", "Continue"} cancel button "Don't Continue" default button "Continue"

EOT

}

# Display dialogue to advise that the remote Mac is currently unreachable/offline

function jamfHelperNetworkCheck ()
{
  su - $LoggedInUser <<'jamfHelper_networkcheck'
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericNetworkIcon.icns -title 'Mac Leavers Data' -heading 'Remote Mac Offline' -description "Unable to change leaver's profile permissions as the remote Mac is currently offline/unreachable.

Please make sure the remote Mac is connected to the corporate network and try again.

  " -button1 "Ok" -defaultButton "1" &
jamfHelper_networkcheck
}

# Display dialogue to advise that the permissions change has failed, possibly due to the network connection being interrupted

function jamfHelperFailure ()
{
  su - $LoggedInUser <<'jamfHelper_failure'
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title 'Mac Leavers Data' -heading 'Profile permissions change failure' -description 'Changing leavers profile permissions interrupted/failed❗️. The remote Mac may be offline.

Please make sure the remote Mac is connected to the corporate network and then try again.

  ' -button1 "Ok" -defaultButton "1" &
jamfHelper_failure
}

# Display dialogue to advise that the leavers profile is not present on the machine specified

function jamfHelperProfileCheck ()
{
  su - $LoggedInUser <<'jamfHelper_profilecheck'
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title 'Mac Leavers Data' -heading 'Profile Check' -description 'Leavers profile not present on remote Mac.

Please make sure you have the correct asset number and then try again.

  ' -button1 "Ok" -defaultButton "1" &
jamfHelper_profilecheck
}

# Check the remote Macs availability and if the leavers profile exists

function checkProfileExists() {
ping -c 1 $remotemac &> /dev/null
if [[ "$?" != "0" ]]; then
  jamfHelperNetworkCheck
  exit 1
else
  if ssh "$LoggedInUser"admin@$remotemac test -e /Users/$ProfTarg; then
    echo "$remotemac is online and $ProfTarg's profile is present"
  else
    jamfHelperProfileCheck
    exit 1
  fi
fi
}

# Check there has been no network interruption during the permissions change and that the profile has been renamed etc

function checkRemoteMacPostCommands() {
ping -c 1 $remotemac &> /dev/null
if [[ "$?" != "0" ]]; then
jamfHelperFailure
exit 1
else
  if ssh "$LoggedInUser"admin@$remotemac test -e /Users/Leaver-$ProfTarg; then
  echo "Profile renamed and permissions changed for $ProfTarg's profile on $remotemac"
  else
    jamfHelperFailure
    exit 1
  fi
fi
}

# Change home directory permissions for leaver

function amendPermissions() {

ssh -t "$LoggedInUser"admin@$remotemac "/usr/bin/sudo bash -c 'chmod -R 777 /Users/$ProfTarg/;
mv /Users/$ProfTarg/ /Users/Leaver-$ProfTarg;'"

checkRemoteMacPostCommands

}

##########################
### script starts here ###
##########################

# Create a temp file to hold the profile name that permissions need to be changed

userName

echo $username > $ProfName

# Set the targeted profile name

ProfTarg=$(head -n 1 $ProfName)

echo $ProfTarg

getRemoteMac

checkProfileExists

changePermissionsCheck

if [[ "$?" != "0" ]]; then

  echo "No permissions will be changed"

else

amendPermissions

checkRemoteMacPostCommands

fi

# Remove the temp file

rm $ProfName

exit 0
