#!/bin/bash

########################################################################
#                Upgrade macOS - self service policy                   #
################# Written by Phil Walker August 2019 ###################
########################################################################

########################################################################
#                         Jamf Variables                               #
########################################################################

osInstallerLocation="$4" #The path the to Mac OS installer is pulled in from the policy for flexability e.g /Users/Shared/Install macOS Sierra.app SPACES ARE PRESERVED
osName="$5" #The nice name for jamfHelper e.g. macOS Mojave.
requiredSpace="$9" #In GB how many are required to complete the update
##DEBUG
#osInstallerLocation="/Applications/Install macOS Mojave.app"
#osName="macOS Mojave"
#requiredSpace="15"

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
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
mobileAccount=$(dscl . read /Users/${loggedInUser} OriginalNodeName 2>/dev/null)

##Title to be used for userDialog (only applies to Utility Window)
title="Message from Bauer IT"

##Headings to be used for userDialog
heading="Please wait as we prepare your computer for $osName..."
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
$osName upgrade.

Please contact the IT Service Desk for assistance"

##Icon to be used for userDialog
##Default is macOS Sierra Installer logo which is included in the staged installer package
icon="$osInstallerLocation"/Contents/Resources/InstallAssistant.icns
icon_warning=/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns

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
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Mobile account detected - upgrade cannot continue!" -description "To resolve this issue a logout/login is required.

In 30 seconds you will be automatically logged out of your current session.
Please log back in to your Mac, launch the Self Service app and run the ${osName} Upgrade.

If you have any further issues please contact the IT Service Desk on 0345 058 4444." -timeout 30 -button1 "Logout" -defaultButton 1
}

function jamfHelperFVMobileAccounts ()
{
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Mobile account detected - upgrade cannot continue!" -description "Please contact the IT Service Desk on 0345 058 4444 before attempting this upgrade again." -button1 "Close" -defaultButton 1
}

function jamfHelperNoSpace ()
{
HELPER_SPACE=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Not enough free space found - upgrade cannot continue!" -description "Please ensure you have at least ${requiredSpace}GB of Free Space
Available Space : ${freeSpace}GB

Please delete files and emtpy yout trash to free up additional space.

If you continue to experience this issue, please contact the IT Service Desk on 0345 058 4444." -button1 "Retry" -button2 "Quit" -defaultButton 1
)
}

function addReconOnBoot ()
{
#Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
#Check if logout policy has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
jamfLogout=$(grep "/usr/local/jamf/bin/jamf policy -trigger logout" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
if [[ -n "$jamfRecon" ]] && [[ -n "$jamfLogout" ]]; then
  echo "Recon and logout policy already entered in startup script"
else
  #Add recon and logout policy to the startup script
  echo "Recon and logout policy not found in startup script adding..."
  #Remove the exit from the file
  sed -i '' "/$exit 0/d" /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  #Add in additional recon line with an exit in
  /bin/echo "## Run Recon and run logout policies" >> /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  /bin/echo "/usr/local/jamf/bin/jamf recon" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  /bin/echo "/usr/local/jamf/bin/jamf policy -trigger logout" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
  /bin/echo "exit 0" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh

    #Re-populate startup script recon check variable
    jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    jamfLogout=$(grep "/usr/local/jamf/bin/jamf policy -trigger logout" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    if [[ -n "$jamfRecon" ]] && [[ -n "$jamfLogout" ]]; then
      echo "Recon and logout policy added to the startup script successfully"
    else
      echo "Recon and logout policy NOT added to the startup script"
    fi
fi
}

function checkPower ()
{
##Check if device is on battery or ac power
pwrAdapter=$( /usr/bin/pmset -g ps )
if [[ ${pwrAdapter} =~ "AC Power" ]]; then
	pwrStatus="OK"
	echo "Power Check: OK - AC Power Detected"
else
	pwrStatus="ERROR"
	echo "Power Check: ERROR - No AC Power Detected"
fi
}

function checkSpace ()
{
##Check if free space > 15GB
osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )
if [[ "$osMinor" -eq "12" ]]; then
	freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}' )
else
  freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}' )
fi

if [ -z ${freeSpace} ]; then
  freeSpace="5"
fi

if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
	echo "Disk Check: OK - ${freeSpace%.*}GB Free Space Detected"
else
	spaceStatus="ERROR"
	echo "Disk Check: ERROR - ${freeSpace%.*}GB Free Space Detected"
fi
}

function checkNoMADLoginAD()
{
  #If a MacBook make sure NoMAD Login AD is installed and the logged in user has a local account
  if [[ "$macModel" =~ "MacBook" ]] && [[ "$osShort" -eq "12" ]]; then
    echo "${macModelFull} running ${osFull}, confirming that NoMAD Login AD is installed..."
    if [[ ! -d "$noLoADBundle" ]]; then
      if [[ "$loggedInUser" != "" ]]; then
        echo "NoMAD Login AD not installed, aborting OS Upgrade"
        jamfHelperNoMADLoginADMissing
        exit 1
      else
        echo "NoMAD Login AD not installed, Aborting OS Upgrade"
        exit 1
      fi
    else
      echo "NoMAD Login AD installed"
        if [[ "$loggedInUser" != "" ]]; then
        echo "Confirming that $loggedInUser has a local account..."
          if [[ "$mobileAccount" == "" ]]; then
            echo "$loggedInUser has a local account, carry on with OS Upgrade"
          else
            echo "$loggedInUser has a mobile account, aborting OS Upgrade"
            echo "Advising $loggedInUser via a jamfHelper that they will be logged out in 30 seconds as a logout/login is required"
            jamfHelperMobileAccount
            echo "killing the login session..."
            killall loginwindow
            exit 1
          fi
        else
          fileVaultStatus=$(fdesetup status | sed -n 1p)
            if [[ "$fileVaultStatus" =~ "Off" ]]; then
              echo "FileVault off, carry on with OS upgrade"
            else
              echo "FileVault is on, checking that all FileVault enabled users have local accounts"
              allUsers=$(dscl . -list /Users | grep -v "^_\|casadmin\|daemon\|nobody\|root\|admin")
                for user in $allUsers
                  do
                    fileVaultUser=$(fdesetup list | grep "$user" | awk  -F, '{print $1}')
                    if [[ "$fileVaultUser" == "$user" ]]; then
                      fvMobileAccount=$(dscl . read /Users/${user} OriginalNodeName 2>/dev/null)
                        if [[ "$fvMobileAccount" == "" ]]; then
                          echo "$user is a FileVault enabled user with a local account"
                        else
                          echo "$user is a FileVault enabled user with a mobile account, aborting upgrade!"
                          echo "Please contact $user and ask them to login to demobilise their account before attempting the upgrade again"
                          jamfHelperFVMobileAccounts
                          exit 1
                        fi
                    fi
                done
            fi
        fi
      fi
  else
    echo "${macModelFull} running ${osFull}, carry on with OS Upgrade"
  fi

}


########################################################################
#                         Script starts here                           #
########################################################################

#Clear any jamfHelper windows
killall jamfHelper 2>/dev/null

echo "Starting Upgrade to $osName with $osInstallerLocation"
echo "$requiredSpace GB will be required to complete."

##Check the installer is downloaded if it's not there throw a jamf helper message
if [[ ! -d "$osInstallerLocation" ]]; then
        echo "No Installer found!"
				/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$icon_warning" -heading "$heading_error" -description "$description_error" -button1 "OK" -defaultButton 1 &
        exit 1
else
        echo "Installer found"
fi

if [ "$loggedInUser" == "" ]; then
  echo "No user logged in"
  #Show status of backup, network, power, sapce for reporting. As no logged in user no action can be taken to fix an issues.
  checkNoMADLoginAD
  checkPower
  checkSpace
  ##Begin Upgrade
  echo "--------------------------"
  echo "Passed all Checks"
  echo "--------------------------"
  echo "Start upgrade"
  addReconOnBoot
  echo "Removing Pre-Mojave mount network shares content..."
  /usr/local/jamf/bin/jamf policy -trigger removemountnetworkshares
  echo "Cleaning font registration database..."
  /usr/local/jamf/bin/jamf policy -trigger cleanfontdatabase_mojaveupgrade
  echo "Launching startosinstall..."
  "$osInstallerLocation"/Contents/Resources/startosinstall --nointeraction --agreetolicense
  /bin/sleep 3
  exit 0
else
  echo "Current logged in user is $loggedInUser"
  #Check if the Mac is a MacBook. If so, make sure NoMAD Login AD is installed and the logged in user has a local account
  checkNoMADLoginAD

  #Check for Power
  checkPower
  while ! [[  ${pwrStatus} == "OK" ]]
  do
    echo "No Power"
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

  echo "--------------------------"
  echo "Passed all Checks"
  echo "--------------------------"
  #Quit all open Apps
  echo "Killing all Microsoft Apps to avoid MS Error Reporting launching"
  ps -ef | grep Microsoft | grep -v grep | awk '{print $2}' | xargs kill -9
  echo "Killing all other open applications for $loggedInUser"
  killall -u "$loggedInUser"
  ##Launch jamfHelper
  echo "Launching jamfHelper..."
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$icon" -heading "$heading" -description "$description" &
  ##Begin Upgrade
  addReconOnBoot
  echo "Removing Pre-Mojave mount network shares content..."
  /usr/local/jamf/bin/jamf policy -trigger removemountnetworkshares
  echo "Cleaning font registration database..."
  /usr/local/jamf/bin/jamf policy -trigger cleanfontdatabase_mojaveupgrade
  echo "Launching startosinstall..."
  "$osInstallerLocation"/Contents/Resources/startosinstall --agreetolicense --nointeraction
  /bin/sleep 3
  exit 0
fi
