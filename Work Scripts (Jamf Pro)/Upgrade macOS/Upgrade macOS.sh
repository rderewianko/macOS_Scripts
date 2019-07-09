#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # REQUIREMENTS:
#			- Jamf Pro
#			- macOS Installer must be packaged and installed, the location is defined as $4
#     -This script runs with an after priority
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# JAMF VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
OSInstallerLocation="$4" #The path the to Mac OS installer is pulled in from the policy for flexability e.g /Users/Shared/Install macOS Sierra.app SPACES ARE PRESERVED
OSInstallerVersion="$5" #The major version of mac OS that will be installed e.g. 12 or 13 to determine is APFS flat needs adding to the startosinstall command.
OSName="$6" #The nice name for jamfHelper e.g. Mac OS Mojave.
requiredSpace="$9" #In GB how many are requried to compelte the update
##DEBUG
#OSInstallerLocation="/Applications/Install macOS Mojave.app"
#requiredSpace="15"
#OSName="Mac OS Mojave"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#  VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
/bin/echo "Current Logged in user is $LoggedInUser"

#Mac model and marketing name
macModel=$(sysctl -n hw.model)
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)

#OS Version Full and Short
OSFull=$(sw_vers -productVersion)
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')

#Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"

#Check the logged in user is a local account
mobileAccount=$(dscl . read /Users/${LoggedInUser} OriginalNodeName 2>/dev/null)

##Title to be used for userDialog (only applies to Utility Window)
title="Message from Bauer IT"

##Headings to be used for userDialog
heading="Please wait as we prepare your computer for $OSName..."
heading_error="Oops... Something went wrong!"
heading_requirements="Requirements Not Met"

##Titles to be used for userDialog
description="This process will take approximately 5-10 minutes. Please do not open any Documents or Applications
Once completed your computer will reboot and begin the upgrade.

During this upgrade you will not have access to your Mac!
It can take up to 60 minutes to complete the upgrade process
before the login window is available. Time for a ☕️ ...

"
description_error="Something has gone wrong with downloading or initialising the
$OSName upgrade.

Please contact the IT Service Desk for assistance"

heading_requirementDescription="We were unable to prepare your computer for $OSName. Please ensure you are connected to power and that you have at least ${requiredSpace}GB of Free Space.

If you continue to experience this issue, please contact the IT Service Desk on 0345 058 4444."
##Icon to be used for userDialog
##Default is macOS Sierra Installer logo which is included in the staged installer package
icon="$OSInstallerLocation"/Contents/Resources/InstallAssistant.icns
icon_warning=/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns

function jamfHelperNoValidTM ()
{
#Show a message via Jamf Helper that the update has Failed.
su - $LoggedInUser <<'jamfmsg4'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "    Mac OS Upgrade cannot be completed    " -description "Your Mac has a backup partition but no backups have been completed today.

Please contact the IT Service Desk for assistance before attempting to upgrade again." -button1 "Ok" -defaultButton "1"
jamfmsg4
}

function jamfHelperNoEthernet ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "No network cable found - upgrade cannot continue!" -description "Please connect a network cable and try again." -button1 "Retry" -defaultButton 1
}

function jamfHelperNoPower ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "No power found - upgrade cannot continue!" -description "Please connect a power cable and try again." -button1 "Retry" -defaultButton 1
}

function jamfHelperNoMADLoginADMissing ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "NoMAD Login AD not installed - upgrade cannot continue!" -description "Please contact the IT Service Desk on 0345 058 4444 before attempting this upgrade again." -button1 "Close" -defaultButton 1
}

function jamfHelperMobileAccount ()
{

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Mobile account detected - upgrade cannot continue!" -description "Please contact the IT Service Desk on 0345 058 4444 before attempting this upgrade again." -button1 "Close" -defaultButton 1
}

function jamfHelperNoSpace ()
{
HELPER_SPACE=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Not enough free space found - upgrade cannot continue!" -description "Please ensure you have at least ${requiredSpace}GB of Free Space
Available Space : ${freeSpace}Gb

Please delete files and emtpy yout trash to free up additional space.

If you continue to experience this issue, please contact the IT Service Desk on 0345 058 4444." -button1 "Retry" -button2 "Quit" -defaultButton 1
)
}

function addReconOnBoot ()
{
  #Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
  if [ ! -z $(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh") ];
  then
      /bin/echo "Rccon already entered in startup script"
  else
      # code if not found
      /bin/echo "Recon not found in startup script adding..."
      #Remove the exit from the file
      sed -i '' "/$exit 0/d" /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
      #Add in additional recon line with an exit in
      /bin/echo /usr/local/jamf/bin/jamf recon >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
      /bin/echo exit 0 >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
      /bin/echo "Recon added to startup"
  fi
}

function checkNetwork ()
{
  currentservice=$(networksetup -listallhardwareports | grep -C1 $(route get default | grep interface | awk '{print $2}'))
  /bin/echo "Network Connected via $currentservice"
}

function checkPower ()
{
##Check if device is on battery or ac power
pwrAdapter=$( /usr/bin/pmset -g ps )
if [[ ${pwrAdapter} == *"AC Power"* ]]; then
	pwrStatus="OK"
	/bin/echo "Power Check: OK - AC Power Detected"
else
	pwrStatus="ERROR"
	/bin/echo "Power Check: ERROR - No AC Power Detected"
fi
}

function checkSpace ()
{
##Check if free space > 15GB
osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )
if [[ $osMinor -eq 12 ]]; then
	freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}' )
else
  freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}' )
fi

if [ -z ${freeSpace} ]; then
  freeSpace="5"
fi

if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
	/bin/echo "Disk Check: OK - ${freeSpace%.*}GB Free Space Detected"
else
	spaceStatus="ERROR"
	/bin/echo "Disk Check: ERROR - ${freeSpace%.*}GB Free Space Detected"
fi
}

function checkTMBackup ()
{
  #Check if Backup partition is present and if so has a backup from today
  todayDate=$(date)
  BackupPartition=$(diskutil list | grep "Backup" | awk '{ print $3 }')
  if [[ "$BackupPartition" != Backup ]]; then
  		/bin/echo "Backup partition could not be found.."
  else
  		/bin/echo "Backup partition found check for a TM backup"
  		DATE=$(date | awk '{print $2,$3,$6}')
  		BackupDate=$(ls -l /Volumes/Backup/Backups.backupdb/* | grep "Latest" | awk '{print $6,$7,$11}' | sed 's/-.*//')

  		if [[ "$DATE" != "$BackupDate" ]]; then
  				/bin/echo "Backup is not recent $BackupDate, Aborting OS Upgrade"
  				jamfHelperNoValidTM
  				exit 0
  		else
  				/bin/echo "TM backup complete on $BackupDate, carry on with OS Upgrade"
  		fi
  fi
}

function checkNoMADLoginAD()
{
#If a MacBook make sure NoMAD Login AD is installed and the logged in user has a local account
if [[ "$macModel" =~ "MacBook" ]] && [[ "$OSShort" == "12" ]]; then
  /bin/echo "${macModelFull} running ${OSFull}, confirming that NoMAD Login AD is installed..."
  if [[ -d "$noLoADBundle" ]]; then
    /bin/echo "NoMAD Login AD installed, confirming that $LoggedInUser has a local account..."
    if [[ "$mobileAccount" == "" ]]; then
      /bin/echo "$LoggedInUser has a local account, carry on with OS Upgrade"
    else
      /bin/echo "$LoggedInUser has a mobile account, Aborting OS Upgrade"
      jamfHelperMobileAccount
      exit 0
    fi
  else
      if [[ "$LoggedInUser" != "" ]]; then
        /bin/echo "NoMAD Login AD not installed, Aborting OS Upgrade"
        jamfHelperNoMADLoginADMissing
        exit 0
      else
        /bin/echo "NoMAD Login AD not installed, Aborting OS Upgrade"
        exit 0
      fi
  fi
else
  /bin/echo "${macModelFull} running ${OSFull}, carry on with OS Upgrade"
fi

}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# START THE SCRIPT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#Clear any jamfHelper windows
killall jamfHelper

/bin/echo "Starting Upgrade to $OSName with $OSInstallerLocation"
/bin/echo "$requiredSpace GB will be required to complete."

##Check the installer is downloaded if it's not there throw a jamf helper message
if [[ ! -d "$OSInstallerLocation" ]]; then
        /bin/echo "No Installer found!"
				/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$icon_warning" -heading "$heading_error" -description "$description_error" -button1 "OK" -defaultButton 1 &
        exit 1
else
        /bin/echo "Installer found"
fi

if [ "$LoggedInUser" == "" ]; then
  #Show status of backup, network, power, sapce for repoting. As no logged in user no action can be taken to fix an issues.
  checkNoMADLoginAD
  checkTMBackup
  checkNetwork
  checkPower
  checkSpace
  ##Begin Upgrade
  /bin/echo "No one home, perform upgrade"
  addReconOnBoot
  /bin/echo "Removing Pre-Mojave mount network shares content..."
  /usr/local/jamf/bin/jamf policy -trigger removemountnetworkshares
  /bin/echo "Launching startosinstall..."
  "$OSInstallerLocation"/Contents/Resources/startosinstall --nointeraction --agreetolicense
  /bin/sleep 3
else
  #Check if the Mac is a MacBook. If so, make sure NoMAD Login AD is installed and the logged in user has a local account
  checkNoMADLoginAD

  #Check for a TM Backup
  #checkTMBackup

  #Check for ethernet before proceeding
  checkNetwork
  while [[ "$currentservice" = *"Wi-Fi"* ]]
  do
    /bin/echo "Wifi connected"
    jamfHelperNoEthernet
    sleep 5
    checkNetwork
  done

  #Check for Power
  checkPower
  while ! [[  ${pwrStatus} == "OK" ]]
  do
    /bin/echo "No Power"
    jamfHelperNoPower
    sleep 5
    checkPower
  done

  #Check the Mac meets the space Requirements
  checkSpace
  while ! [[  ${spaceStatus} == "OK" ]]
  do
    /bin/echo "Not enough Space"
    jamfHelperNoSpace
    if [ "$HELPER_SPACE" == "2" ]; then
      /bin/echo "User clicked quit at lack of space message"
      exit 1
    fi
    sleep 5
    checkSpace
  done

  /bin/echo "--------------------------"
  /bin/echo "Passed all Checks"
  /bin/echo "--------------------------"
  /bin/echo "Killing all open applications for $LoggedInUser"
  killall -u $LoggedInUser
  ##Launch jamfHelper
  /bin/echo "Launching jamfHelper..."
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$icon" -heading "$heading" -description "$description" &
  ##Begin Upgrade
  addReconOnBoot
  /bin/echo "Removing Pre-Mojave mount network shares content..."
  /usr/local/jamf/bin/jamf policy -trigger removemountnetworkshares
  /bin/echo "Launching startosinstall..."
  "$OSInstallerLocation"/Contents/Resources/startosinstall --agreetolicense --nointeraction
  /bin/sleep 3
fi
