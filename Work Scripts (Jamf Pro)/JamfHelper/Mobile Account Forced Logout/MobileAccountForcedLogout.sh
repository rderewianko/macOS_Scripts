#!/bin/bash

########################################################################
#                   Mobile Account Forced logout                       #
################## Written by Phil Walker Oct 2019 #####################
########################################################################

#This script is designed to be used with JamfPro and script variables
#when selecting via a policy

########################################################################
#                            Variables                                 #
########################################################################

policyTrigger="$4" #What unique policy trigger actually performs the action
deferralOption1="$5" #deferral time option 1 e.g 0, 300, 3600, 10800 (Now, 5 minutes, 1 hour, 3 hours)
deferralOption2="$6" #deferral time option 2 e.g 0, 300, 3600, 10800 (Now, 5 minutes, 1 hour, 3 hours)
deferralOption3="$7" #deferral time option 3 e.g 0, 300, 3600, 10800 (Now, 5 minutes, 1 hour, 3 hours)
deferralOption4="$8" #deferral time option 4 e.g 0, 300, 3600, 10800 (Now, 5 minutes, 1 hour, 3 hours)

#Get the current logged in user and store in variable
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Mac model and marketing name
macModel=$(sysctl -n hw.model)
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)

#OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')

#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

#Check the logged in user is a local account
mobileAccount=$(dscl . -read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)

#FileVault status
fileVaultStatus=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)

#Get the logged in user's GUID
loggedInUserGUID=$(/usr/bin/dscl . -read /Users/$loggedInUser GeneratedUID | awk '{print $2}')

#Get the logged in user's FileVault status
loggedInUserFVStatus=$(/usr/bin/fdesetup list 2>/dev/null | grep "$loggedInUser" | awk  -F, '{print $2}')

########################################################################
#                            Functions                                 #
########################################################################

function fileVaultStatus ()
{
#Check FileVault status and confirm the logged in user is a FV2 enabled user
if [[ "$fileVaultStatus" =~ "On" ]]; then
  echo "FileVault is on, checking ${loggedInUser}'s FileVault status..."
    if [[ "$loggedInUserGUID" == "$loggedInUserFVStatus" ]]; then
      echo "${loggedInUser} is a FileVault enabled user, continuing"
    else
      echo "${loggedInUser} is not a FileVault enabled user, exiting..."
      exit 0
    fi
else
  echo "FileVault is currently off, nothing to do"
  exit 0
fi

}

function mobileAccount ()
{
#Confirm device is a MacBook with NoMAD Login AD installed and the logged in user has a mobile account
if [[ "$macModel" =~ "MacBook" ]] && [[ "$osShort" -eq "12" ]]; then
  echo "${macModelFull} running ${osFull}, confirming that NoMAD Login AD is installed..."
    if [[ -d "$noLoADBundle" ]]; then
      echo "NoMAD Login AD installed"
        if [[ "$mobileAccount" != "" ]]; then
          echo "${loggedInUser} has a mobile account, logout/login required"
        else
          echo "${loggedInUser} has a local account, nothing to do"
          exit 0
        fi
    fi
else
  echo "${macModelFull} running ${osFull}, nothing to do"
  exit 0
fi

}

function jamfHelperFullScreen ()
#Full screen jamfHelper to advise that a logout/login is required to demobilise account
{
su - $loggedInUser <<'jamfmsg'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -icon /System/Library/CoreServices/Software\ Update.app/Contents/Resources/SoftwareUpdate.icns -title "Message from Bauer IT" -heading "macOS Mojave Upgrade Preparation" -alignHeading center -description "To prepare your Mac for macOS Mojave a logout is required

Vital changes will be made during your next logon that are required before your Mac can be upgraded"  -button1 "ok" defaultbutton "1" -timeout 5 &

jamfmsg
}

function jamfHelperLogoutDeferral ()
#Provide deferral options for the logout with deferral options supplied by the policy
{
HELPER=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GroupIcon.icns -title "Message from Bauer IT" -heading "   macOS Mojave Upgrade Preparation   " -alignHeading center -description "Please select the most convenient time to logout from the drop down menu

Make sure to save all of your work as you will be logged out automatically after the time selected has elapsed

Once the logout has completed please log back in as normal" -lockHUD -showDelayOptions "$deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4"  -button1 "Select"

)
}

function jamfHelperUpdateDeferralConfirm ()
{
#Advise the user of the selected deferral
#Convert the seconds chosen to human readable days, minutes, hours. No Seconds are calulated
local T=$deferralTime;
local D=$((T/60/60/24));
local H=$((T/60/60%24));
local M=$((T/60%60));
timeChosenHuman=$(printf '%s' "Your current session will be ended in: "; [[ $D > 0 ]] && printf '%d days ' $D; [[ $H -eq 1 ]] && printf '%d hour' $H; [[ $H -ge 2 ]] && printf '%d hours' $H; [[ $M > 0 ]] && printf '%d minutes' $M; [[ $D > 0 || $H > 0 || $M > 0 ]] )
#Show a message via Jamf Helper that the update will be installed after the deferral time chosen
HELPER_DEFERRAL_CONFIRM=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GroupIcon.icns -title "Message from Bauer IT" -heading "   macOS Mojave Upgrade Preparation   " -alignHeading center -description "${timeChosenHuman}" -timeout 10  -button1 "Ok" -defaultButton 1 &
)
}

function jamfHelperLogoutNow ()
{
#Show a message via Jamf Helper that the current login session will be ended in 1 minute
su - $loggedInUser <<'jamfmsg2'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GroupIcon.icns -title "Message from Bauer IT" -heading "   macOS Mojave Upgrade Preparation   " -description "The deferral time has now elapsed and your current session will be ended in 1 minute

Once the logout has completed please log back in as normal" &
jamfmsg2
}

function performLogout ()
{

#Kill the deferal file before the login session is ended
rm -f /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt 2>/dev/null
if [ -e /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt ]; then
    echo "Something went wrong, the deferral timer file is still present"
else
    echo "Deferral file removed after the policy was triggered"
fi

#Call the policy to force a logout
/usr/local/jamf/bin/jamf policy -trigger $policyTrigger

}


########################################################################
#                         Script starts here                           #
########################################################################

if [ "$loggedInUser" == "" ]; then
    echo "No logged in user, nothing to do"
    exit 0
  else
    fileVaultStatus
    mobileAccount
    #Check if the deferral file exists, if not create, if it does read the value and add to a variable
    if [ ! -e /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt ]; then
        touch /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt
    else
        deferralTime=$(cat /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt)
        echo "Deferral file present with $deferralTime seconds"
    fi
    jamfHelperFullScreen
    sleep 30s
    killall jamfHelper
    #Read the deferral time from the file, incase Mac got rebooted. This will determine the next step
    deferralTime=$(cat /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt)

    if [[ -z $deferralTime ]]; then #No Deferral time set so we can now ask the user to set one
      echo "$loggedInUser now being asked to select a convenient time to logout. Following options available $deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4 "
      #Run function to show jamf Helper message to ask user to set deferral time
      jamfHelperLogoutDeferral
      #Format the dropdown result from JamfHlper as a 1 gets added at the end when the button is pressed
      timeChosen="${HELPER%?}"
      #Save the selected deferral time to a text file and then add to the variable
      echo "$timeChosen" > /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt
      deferralTime=$(cat /Library/Application\ Support/JAMF/.Deferral-${policyTrigger}.txt)

      if [ "$HELPER" == "1" ]; then #Option1 is always 0 seconds so no deferral
          echo "$deferralOption1 selected logout now"
          performLogout

      else # A deferral time was selected from the dropdown menu, show user what was selected
        jamfHelperUpdateDeferralConfirm #Message auto closes after 10 seconds
        echo "Wait for $deferralTime before running $policyTrigger"
        sleep $deferralTime
          #Confirm session will be ended in 1 minute
          jamfHelperLogoutNow
          sleep 60s
          performLogout
        fi
    else # A deferral time has already been set and saved in the .Deferral-${policyTrigger}.txt file
      echo "$loggedInUser already has a deferal time set of $deferralTime, wait for deferral time then ask to apply update"
      echo "Wait for $deferralTime before running $policyTrigger"
      sleep $deferralTime
        #Confirm session will be ended in 1 minute
        jamfHelperLogoutNow
        sleep 60s
        performLogout
    fi
fi
