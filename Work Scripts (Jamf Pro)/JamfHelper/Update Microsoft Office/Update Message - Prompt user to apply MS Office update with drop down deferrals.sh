#!/bin/bash

########################################################################
#   Update Microsoft Office to 2019/365 script with deferral options   #
################## Written by Phil Walker July 2019 ####################
########################################################################

#This script is designed to be used with JamfPro. Script variables
#are set via the policy

########################################################################
#                            Variables                                 #
########################################################################

PolicyTrigger="$4" #What unique policy trigger actually installs the package
deferralOption1="$5" #deferral time option 1 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)
deferralOption2="$6" #deferral time option 2 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)
ApplicationName="$9" #Application name to be used in Jamf Helper windows

#Get the current logged in user and store in variable
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Check if the deferral file exists, if not create, if it does read the value and add to a variable
if [ ! -e /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt ]; then
    touch /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt
else
    DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt)
    echo "Deferral file present with $DeferralTime Seconds"
fi
########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperApplyUpdate ()
#Prompt user to update Microsoft Teams with deferral options supplied by the policy
{
HELPER=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -title "Message from Bauer IT" -heading "${ApplicationName} is waiting to be installed" -alignHeading center -description "${ApplicationName} brings new features, bug fixes and security patches.

You can choose to start the install now or select one of the deferral times if you currently require the use of any Microsoft Office apps. The installation can take up to 20 minutes to complete.

Please make sure you do not need to use any of the Microsoft Office apps before the update starts!

If you do not select an option during the 1 hour countdown the update will be installed automatically." -lockHUD -timeout 3600 -countdown -showDelayOptions "$deferralOption1, $deferralOption2"  -button1 "Select" -defaultButton "1"

)
}

function jamfHelperUpdateConfirm ()
{
#Show a message via Jamf Helper that the update is ready, this is after it has been deferred
HELPER_CONFIRM=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -title "Message from Bauer IT" -heading "    ${ApplicationName} is waiting to be installed     " -description "${ApplicationName} brings new features, bug fixes and security patches

All Microsoft Office apps will be closed automatically during the update process" -lockHUD -timeout 21600 -button1 "Install" -defaultButton "1"
)
}

function jamfHelperUpdateDeferralConfirm ()
{
#Advise the user of the selected deferral
#Convert the seconds chosen to human readable days, minutes, hours. No Seconds are calulated
local T=$DeferralTime;
local D=$((T/60/60/24));
local H=$((T/60/60%24));
local M=$((T/60%60));
timeChosenHuman=$(printf '%s' "${ApplicationName} will be installed in: "; [[ $D > 0 ]] && printf '%d days ' $D; [[ $H -eq 1 ]] && printf '%d hour' $H; [[ $H -ge 2 ]] && printf '%d hours' $H; [[ $M > 0 ]] && printf '%d minutes' $M; [[ $D > 0 || $H > 0 || $M > 0 ]] )
#Show a message via Jamf Helper that the update will be installed after the deferral time chosen
HELPER_DEFERRAL_CONFIRM=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    $timeChosenHuman      " -description "If you would like to install ${ApplicationName} sooner please open Self Service and navigate to the Applications section" -timeout 10  -button1 "Ok" -defaultButton "1" &
)
}

function jamfHelperUpdateInProgress ()
{
#Show a message via Jamf Helper that the update is in progress
su - $LoggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    Microsoft Office 2019 installation in progress     " -description "All Microsoft Office apps will be closed automatically during the update process" &
jamfmsg1
}

function jamfHelperUpdateComplete ()
{
#Show a message via Jamf Helper that the update is ready, this is after it has been deferred
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    ${ApplicationName} installation complete     " -description "${ApplicationName} has been successfully installed" -timeout 30 -button1 "Ok" -defaultButton "1"
}

function installerWhile ()
{
#While the installer porcess is running we wait, this leaves the jamf helper message up. Once installation is complete the message is killed
while ps axg | grep -vw grep | grep -w installer > /dev/null;
do
        echo "Installer running"
        sleep 1;
done
echo "Installer Finished"
killall jamfHelper
}

function performUpdate ()
{

#Call jamf Helper to show message update has started
jamfHelperUpdateInProgress

#Call the policy to run the update
/usr/local/jamf/bin/jamf policy -trigger "$PolicyTrigger"

#Call while loop to check when the installer process is finished so jamf helper can be killed
installerWhile

#Kill the deferal file after the update has been compelted so this script can be re-used
rm /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt
if [ -e /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt ]; then
    echo "Something went wrong, the deferral timer file is still present"
else
    echo "Deferral file removed as update ran"
fi

}


########################################################################
#                         Script starts here                           #
########################################################################

if [ "$LoggedInUser" == "" ]; then
    echo "No logged in user, apply ${ApplicationName} update."
    #Call jamf Helper to show message update has started - catches logout trigger
    performUpdate
  else
    #Read the deferral time from the file, incase Mac got rebooted. This will determine the next step
    DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt)

    if [[ -z $DeferralTime ]]; then #No Deferral time set so we can now ask the user to set one
      echo "$LoggedInUser will be asked to install $PolicyTrigger with the deferral options $deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4 "
      #Run function to show jamf Helper message to ask user to set deferral time
      jamfHelperApplyUpdate
      #Format the dropdown result from JamfHlper as a 1 gets added at the end when the button is pressed
      timeChosen="${HELPER%?}"
      #Save the selected deferral time to a text file and then add to the variable
      echo "$timeChosen" > /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt
      DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-${PolicyTrigger}.txt)

      if [ "$HELPER" == "1" ]; then #Option1 is always 0 seconds so no deferral
          echo "$deferralOption1 Selected run it now"
          performUpdate
          #Call jamf Helper to show message that the installation has completed
          jamfHelperUpdateComplete
      else # A deferral time was selected from the dropdown menu, show user what was selected
        jamfHelperUpdateDeferralConfirm #Message auto closes after 10 seconds
        echo "Wait for $DeferralTime before running $PolicyTrigger"
        sleep $DeferralTime
          #Confirm updates are now going to be installed
          jamfHelperUpdateConfirm
          if [ "$HELPER_CONFIRM" == "0" ]; then
            performUpdate
            #Call jamf Helper to show message that the installation has completed
            jamfHelperUpdateComplete
          fi
        fi
    else # A deferral time has already been set and saved in the .UpdateDeferral-${PolicyTrigger}.txt file
      echo "$LoggedInUser already has a deferal time set of $DeferralTime, wait for deferral time then ask to apply update"
      echo "Wait for $DeferralTime before running $PolicyTrigger"
      sleep $DeferralTime
        #Confirm updates are now going to be installed
        jamfHelperUpdateConfirm
        if [ "$HELPER_CONFIRM" == "0" ]; then
          performUpdate
          #Call jamf Helper to show message that the installation has completed
          jamfHelperUpdateComplete
        fi
    fi
fi
