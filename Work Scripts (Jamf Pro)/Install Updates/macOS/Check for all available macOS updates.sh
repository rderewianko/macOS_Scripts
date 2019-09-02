#!/bin/bash

########################################################################
#            Check for all available macOS updates (Apple CDN)         #
########### Written by Phil Walker and Suleyman Twana July 2019 ########
########################################################################

#This script is designed to be used with JamfPro
#The script variables are set in the policy

########################################################################
#                            Variables                                 #
########################################################################

PolicyTrigger="$4" #What unique policy trigger actually installs the package
deferralOption1="$5" #deferral time option 1 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)
deferralOption2="$6" #deferral time option 2 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)
deferralOption3="$7" #deferral time option 3 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)
deferralOption4="$8" #deferral time option 4 e.g 0, 300, 3600, 21600 (Now, 5 minutes, 1 hour, 6 hours)

#DEBUG
#PolicyTrigger="ApplymacOSUpdate"
#deferralOption1="0"
#deferralOption2="1800"
#deferralOption3="3600"
#deferralOption4="10800"

macOSUpdateVersion=$(softwareupdate -l | grep -vi "Command" | grep -i "macOS" | awk 'NR==2 {print $1,$2}')
macOSUpdate=$(echo "$macOSUpdateVersion" | awk '{print $1}')


#Get the current logged in user and store in variable
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Check if the deferral file exists, if not create, if it does read the value and add to a variable
if [[ ! -e /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt ]]; then
    touch /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt
else
    DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt)
    echo "Deferral file present with $DeferralTime Seconds"
fi

########################################################################
#                            Functions                                 #
########################################################################

#Prompt user to install macOS updates with deferral options supplied by the policy
function jamfHelperApplyUpdate ()
{
HELPER=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -title "Message from Bauer IT" -heading "${macOSUpdateVersion} update is ready and waiting to be installed" -alignHeading center -description "The update is Important to fix macOS bugs, apply the latest security patches and enhance the performance of your Mac.

You may choose to install the ${macOSUpdateVersion} update now or select one of the deferral times if you want to finish your current work. After the deferral time lapses the update will be automatically installed.
Please make sure you save all your work before the update starts!
The update could take up to 40 minutes.

If you do not select an option during the 8 hour countdown the update will be installed automatically." -lockHUD -timeout 28800 -countdown -showDelayOptions "$deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4" -button1 "Select" -defaultButton "1"
)
}

#Show a message via Jamf Helper that the update is ready, this is after it has been deferred
function jamfHelperUpdateConfirm ()
{
HELPER_CONFIRM=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -title "Message from Bauer IT" -heading "    ${macOSUpdateVersion} update is now ready to be installed     " -description "This update is important to keep your Mac up-to-date.

${macOSUpdateVersion} update will now be installed and your Mac will automatically restart after the installation has completed." -lockHUD -timeout 21600 -button1 "Install" -defaultButton "1"
)
}

#Advise the user of the selected deferral
#Convert the seconds chosen to human readable days, minutes, hours. No Seconds are calulated
function jamfHelperUpdateDeferralConfirm ()
{
local T=$DeferralTime;
local D=$((T/60/60/24));
local H=$((T/60/60%24));
local M=$((T/60%60));
timeChosenHuman=$(printf '%s' "${macOSUpdateVersion} update will be installed in: "; [[ $D > 0 ]] && printf '%d days ' $D; [[ $H -eq 1 ]] && printf '%d hour' $H; [[ $H -ge 2 ]] && printf '%d hours' $H; [[ $M > 0 ]] && printf '%d minutes' $M; [[ $D > 0 || $H > 0 || $M > 0 ]] )
# Show a message via Jamf Helper that the updates will be installed after the deferral time chosen
HELPER_DEFERRAL_CONFIRM=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    $timeChosenHuman      " -description "If you would like to install the update sooner please open Self Service and navigate to Updates section and select macOS Updates Install." -timeout 10  -button1 "Ok" -defaultButton "1" &
)
}

#Show a message via Jamf Helper that the update is in progress
function jamfHelperUpdateInProgress ()
{
su - $loggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    macOS update in progress     " -description "A macOS update is now installing...
Please DO NOT shutdown or reboot your Mac during the installation process.
Your Mac will reboot automatically once the update is installed." &
jamfmsg1
}

#Show a message via Jamf Helper that the update has been installed
function jamfHelperUpdateComplete ()
{
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "    ${macOSUpdateVersion} update complete     " -description "${macOSUpdateVersion} update has been successfully installed." -timeout 30 -button1 "Ok" -defaultButton "1"
}

function addReconOnBoot ()
{
#Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
#Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
if [[ -n "$jamfRecon" ]]; then
  echo "Recon already entered in startup script"
else
  #Add recon to the startup script
  echo "Recon not found in startup script adding..."
  #Remove the exit from the file
  sed -i '' "/$exit 0/d" /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  #Add in additional recon line with an exit in
  /bin/echo "## Run Recon" >> /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  /bin/echo "/usr/local/jamf/bin/jamf recon" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  /bin/echo "exit 0" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh

    #Re-populate startup script recon check variable
    jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    if [[ -n "$jamfRecon" ]]; then
      echo "Recon added to the startup script successfully"
    else
      echo "Recon NOT added to the startup script"
    fi

fi
}

#While the installer porcess is running we wait, this leaves the jamf helper message up. Once installation is complete the message is killed
function installerWhile ()
{
while ps axg | grep -vw grep | grep -w installer > /dev/null;
do
        echo "Installer running"
        sleep 1;
done
echo "Installer Finished"
killall jamfHelper > /dev/null 2>&1
}

#Call jamf Helper to show message update has started
function performUpdate ()
{
jamfHelperUpdateInProgress

addReconOnBoot

#Call the policy to run the update
/usr/local/jamf/bin/jamf policy -trigger "$PolicyTrigger"

#Call while loop to check when the installer process is finished so jamf helper can be killed
installerWhile

#Kill the deferal file after the update has been compelted so this script can be re-used
rm /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt
if [[ -e /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt ]]; then
    echo "Something went wrong, the deferral timer file is still present"
else
    echo "Deferral file removed as update ran"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "${macOSUpdate}" =~ "macOS" ]]; then
		echo "macOS update is available"

#If there is no logged in user, install the updates
	if [[ "$loggedInUser" == "" ]]; then
    	echo "No logged in user, apply security update."

    performUpdate
    #Call the policy to restart the Mac
    /usr/local/jamf/bin/jamf policy -trigger "immediate_restart"
else

#Read the deferral time from the file, incase Mac got rebooted. This will determine the next step
DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt)
	if [[ -z $DeferralTime ]]; then #No Deferral time set so we can now ask the user to set one
      echo "$loggedInUser will be asked to install $PolicyTrigger with the deferral options $deferralOption1, $deferralOption2, $deferralOption3, $deferralOption4 "

#Run function to show jamf Helper message to ask user to set deferral time
jamfHelperApplyUpdate

#Format the dropdown result from JamfHlper as a 1 gets added at the end when the button is pressed
timeChosen="${HELPER%?}"

#Save the selected deferral time to a text file and then add to the variable
      echo "$timeChosen" > /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt
DeferralTime=$(cat /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt)
	if [ "$HELPER" == "1" ]; then #Option1 is always 0 seconds so no deferral
		echo "$deferralOption1 Selected run it now"
performUpdate

#Call jamf Helper to show message that the installation has completed
jamfHelperUpdateComplete
#Call the policy to restart the Mac
/usr/local/jamf/bin/jamf policy -trigger "immediate_restart"
else # A deferral time was selected from the dropdown menu, show user what was selected
jamfHelperUpdateDeferralConfirm #Message auto closes after 10 seconds
		echo "Wait for $DeferralTime before running $PolicyTrigger"
sleep $DeferralTime

#Confirm updates are now going to be installed
jamfHelperUpdateConfirm
	if [[ "$HELPER_CONFIRM" == "0" ]]; then
performUpdate

#Call jamf Helper to show message that the installation has completed
jamfHelperUpdateComplete
#Call the policy to restart the Mac
/usr/local/jamf/bin/jamf policy -trigger "immediate_restart"
	fi
fi
else # A deferral time has already been set and saved in the .UpdateDeferral-${PolicyTrigger}.txt file
		echo "$loggedInUser already has a deferal time set of $DeferralTime, wait for deferral time then ask to apply update"
		echo "Wait for $DeferralTime before running $PolicyTrigger"
sleep $DeferralTime

#Confirm updates are now going to be installed
jamfHelperUpdateConfirm
	if [[ "$HELPER_CONFIRM" == "0" ]]; then
performUpdate

#Call jamf Helper to show message that the installation has completed
jamfHelperUpdateComplete
#Call the policy to restart the Mac
/usr/local/jamf/bin/jamf policy -trigger "immediate_restart"


          	fi
        fi
    fi
fi
	if [[ "${macOSUpdate}" != "macOS" || "${macOSUpdate}" == "" ]]; then
	rm /Library/Application\ Support/JAMF/.UpdateDeferral-"$PolicyTrigger".txt
		echo "macOS update is not available"
fi
exit 0
