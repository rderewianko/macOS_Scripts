#!/bin/bash

########################################################################
#                 Upgrade macOS with user deferrals                    #
################# Written by Phil Walker August 2019 ###################
########################################################################
# Edited July 2020

#Installer to be deployed separately

########################################################################
#                         Jamf Variables                               #
########################################################################

osInstallerLocation="$4" #The path the to Mac OS installer is pulled in from the policy for flexability e.g /Applications/Install macOS Catalina.app SPACES ARE PRESERVED
requiredSpace="$5" #In GB how many are requried to compelte the update
osName="$6" #The nice name for jamfHelper e.g. macOS Catalina.
policyName="$9" #Policy name for deferral file.

##DEBUG
#osInstallerLocation="/Applications/Install macOS Catalina.app"
#requiredSpace="15"
#osName="macOS Catalina"
#policyName="macOSCatalinaUpgrade" #Policy name for deferral file.

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Mac model
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# OS Version
osFull=$(sw_vers -productVersion)
# Path to NoMAD Login AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
# Check the logged in user is a local account
mobileAccount=$(dscl . read /Users/"$loggedInUser" OriginalNodeName 2>/dev/null)
# Check we have the timer file and if not create it and populate with 3
# which represents the number of defers the end user will have
if [[ ! -e "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt" ]]; then
    echo "3" > "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt"
fi
# Get the value of the timer file and store for later
Timer=$(cat "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt")
# Go get the Catalina icon
curl -s --url https://images.bauermedia.co.uk/JamfPro/macOS-Catalina-icon.png > /var/tmp/macOS-Catalina-icon.png
# Jamf Helper variables
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Icons
helperIconCatalina="/var/tmp/macOS-Catalina-icon.png"
helperIconCatalinaInstall="${osInstallerLocation}/Contents/Resources/InstallAssistant.icns"
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Title
helperTitle="Message from Bauer IT"
# Heading
helperHeading="An important upgrade is availabe for your Mac - ${Timer} deferral(s) remaining"
# Description
helperDescription="The ${osName} upgrade includes new features, security updates and performance enhancements.

Would you like to upgrade now? You may choose not to upgrade to ${osName} now, but after ${Timer} deferrals your mac will be automatically upgraded.

During this upgrade, you will not have access to your computer! The upgrade can take up to 1 hour to complete.

If using a laptop please make sure you are connected to power.

You must ensure all work is saved before clicking the 'Upgrade Now' button. All of your files and Applications will remain exactly as you leave them.

You can also trigger the upgrade via the Self Service Application at any time e.g. over lunch or just before you leave for the day.

                                                                                                                                    "

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperAsktoUpgrade ()
{
HELPER=$( "$jamfHelper" -windowType utility -icon "$helperIconCatalina" -title "$helperTitle" -alignHeading center \
-heading "$helperHeading" -description "$helperDescription" -timeout 14400 -countdown -alignCountdown center \
-button1 "Later" -button2 "Upgrade Now" -defaultButton "2" )
}

function jamfHelperUpdateConfirm ()
{
# Show a message via Jamf Helper that the update is ready, this is after it has been deferred
"$jamfHelper" -windowType utility -icon "$helperIconCatalinaInstall" -title "$helperTitle" -heading "    ${osName} upgrade is now ready to be installed     " \
-description "This upgrade includes new features, security updates and performance enhancements.

Your Mac will restart once complete!

Please save all of your work before clicking install" -timeout 14400 -countdown -alignCountdown center -button1 "Install" -defaultButton "1"
}

function jamfHelperInProgress ()
{
"$jamfHelper" -windowType utility -icon "$helperIconCatalinaInstall" -title "$helperTitle" -heading "Please wait as we prepare your computer for ${osName}..." \
-description "This process will take approximately 5-10 minutes. Please do not open any documents or applications.
Once completed your computer will reboot and begin the upgrade.

During this upgrade you will not have access to your Mac!
It can take up to 60 minutes to complete the upgrade process.
Time for a ☕️ ...

" &
}

function jamfHelperNoPower ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "No power found - upgrade cannot continue!" \
-description "Please connect a power cable and try again." -button1 "Retry" -defaultButton 1
}

function jamfHelperNoMADLoginADMissing ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "NoMAD Login AD not installed - upgrade cannot continue!" \
-description "Please contact the IT Service Desk on 0345 058 4444 before attempting this upgrade again." -button1 "Close" -defaultButton 1
}

function jamfHelperMobileAccount ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Mobile account detected - upgrade cannot continue!" \
-description "To resolve this issue a logout/login is required.

In 30 seconds you will be automatically logged out of your current session.
Please log back in to your Mac, launch the Self Service app and run the ${osName} Upgrade.

If you have any further issues please contact the IT Service Desk on 0345 058 4444." -timeout 30 -button1 "Logout" -defaultButton 1
}

function jamfHelperFVMobileAccounts ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Mobile account detected - upgrade cannot continue!" \
-description "Please contact the IT Service Desk on 0345 058 4444 before attempting this upgrade again." -button1 "Close" -defaultButton 1
}

function jamfHelperNoSpace ()
{
HELPER_SPACE=$(
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Not enough free space found - upgrade cannot continue!" \
-description "Please ensure you have at least ${requiredSpace}GB of free space
Available Space : ${freeSpace}Gb

Please delete files and empty your trash to free up additional space.

If you continue to experience this issue, please contact the IT Service Desk on 0345 058 4444." -button1 "Retry" -button2 "Quit" -defaultButton 1
)
}

function addReconOnBoot ()
{
# Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
if [[ -n "$jamfRecon" ]]; then
    echo "Recon already entered in startup script"
else
    # Add recon to the startup script
    echo "Recon not found in startup script adding..."
    # Remove the exit from the file
    sed -i '' "/$exit 0/d" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    # Add in additional recon line with an exit in
    /bin/echo "## Run Recon" >> "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    /bin/echo "/usr/local/jamf/bin/jamf recon" >>  "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    /bin/echo "exit 0" >>  "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"

    # Re-populate startup script recon check variable
    jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    if [[ -n "$jamfRecon" ]]; then
        echo "Recon added to the startup script successfully"
    else
        echo "Recon NOT added to the startup script"
    fi
fi
}

function checkPower ()
{
# Check if the device is on AC power or has over 90% battery power
pwrAdapter=$(/usr/bin/pmset -g ps)
batteryPercentage=$(/usr/bin/pmset -g ps | grep -i "InternalBattery" | awk '{print $3}' | cut -c1-3 | sed 's/%//g')
if [[ "$pwrAdapter" =~ "AC Power" ]] || [[ "$batteryPercentage" -ge "90" ]]; then
    pwrStatus="OK"
	echo "Power Check: OK - AC Power Detected"
else
	pwrStatus="ERROR"
	echo "Power Check: ERROR - No AC Power Detected"
fi
}

function checkSpace ()
{
# Check if free space > 15GB
freeSpace=$(/usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}')
if [[ -z "$freeSpace" ]]; then
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

function checkNoMADLoginAD ()
{
# Make sure NoMAD Login AD is installed and the logged in user has a local account
echo "${macModelFull} running ${osFull}, confirming that NoMAD Login AD is installed..."
if [[ ! -d "$noLoADBundle" ]]; then
    if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
        echo "NoMAD Login AD not installed, Aborting OS Upgrade"
        exit 1
    else
        echo "NoMAD Login AD not installed, aborting OS Upgrade"
        jamfHelperNoMADLoginADMissing
        exit 1
    fi
else
    echo "NoMAD Login AD installed"
    if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
        fileVaultStatus=$(fdesetup status | sed -n 1p)
        if [[ "$fileVaultStatus" =~ "Off" ]]; then
            echo "FileVault off, carry on with OS upgrade"
        else
            echo "FileVault is on, checking that all FileVault enabled users have local accounts"
            allUsers=$(dscl . -list /Users | grep -v "^_\|casadmin\|daemon\|nobody\|root\|admin")
            for user in $allUsers; do
                fileVaultUser=$(fdesetup list | grep "$user" | awk  -F, '{print $1}')
                if [[ "$fileVaultUser" == "$user" ]]; then
                    fvMobileAccount=$(dscl . read /Users/"$user" OriginalNodeName 2>/dev/null)
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
    else
        echo "Confirming that $loggedInUser has a local account..."
        if [[ "$mobileAccount" == "" ]]; then
            echo "$loggedInUser has a local account, carry on with OS Upgrade"
        else
            echo "$loggedInUser has a mobile account, aborting OS Upgrade"
            echo "Advising $loggedInUser via a jamfHelper that they will be logged out in 30 seconds as a logout/login is required"
            jamfHelperMobileAccount
            echo "Returning to the login window to demobilise the account on next login..."
            killall loginwindow
            exit 1
        fi
    fi
fi
}

function runInstall ()
{
# Check NoMAD Login AD is installed and the logged in user has a local account
checkNoMADLoginAD

# Check power status
checkPower
while ! [[  ${pwrStatus} == "OK" ]]; do
    echo "No Power"
    jamfHelperNoPower
    sleep 5
    checkPower
done

# Check the Mac meets the space Requirements
checkSpace
while ! [[  ${spaceStatus} == "OK" ]]; do
    echo "Not enough Space"
    jamfHelperNoSpace
    if [[ "$HELPER_SPACE" -eq "2" ]]; then
        echo "User clicked quit at lack of space message"
        exit 1
    fi
    sleep 5
    checkSpace
done

echo "Ask for final agreement to upgrade"
jamfHelperUpdateConfirm

echo "--------------------------"
echo "Passed all Checks"
echo "--------------------------"
# Quit all open Apps
echo "Killing all Microsoft Apps to avoid MS Error Reporting launching"
ps -ef | grep Microsoft | grep -v grep | awk '{print $2}' | xargs kill -9
echo "Killing all other open applications for $loggedInUser"
killall -u "$loggedInUser"
# Launch jamfHelper
echo "Launching jamfHelper..."
jamfHelperInProgress
# Begin Upgrade
addReconOnBoot
echo "Launching startosinstall..."
"$osInstallerLocation"/Contents/Resources/startosinstall --agreetolicense --nointeraction
sleep 3

exit 0
}

########################################################################
#                         Script starts here                           #
########################################################################

# Clear any jamfHelper windows
killall jamfHelper 2>/dev/null
echo "Starting upgrade to $osName with $osInstallerLocation"
echo "$requiredSpace GB will be required to complete."
# Check the installer is downloaded if it's not there exit
if [[ ! -d "$osInstallerLocation" ]]; then
    echo "No Installer found!"
    echo "Check available disk space and the result of the policy to install macOS Catalina"
    exit 1
else
    echo "Installer found, continuing with upgrade"
fi
# Installer found, check to see if a user is logged in
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
    # Show status of NoLoAD, power and space for reporting. As no user is logged in no action can be taken to fix any issues.
    checkNoMADLoginAD
    checkPower
    checkSpace
    # Begin Upgrade
    echo "--------------------------"
    echo "Passed all Checks"
    echo "--------------------------"
    echo "Start upgrade"
    addReconOnBoot
    echo "Launching startosinstall..."
    "$osInstallerLocation"/Contents/Resources/startosinstall --nointeraction --agreetolicense
    sleep 3
  exit 0
else
    echo "Current logged in user is $loggedInUser"
    # Check the value of the timer variable, if greater than 0 i.e. can defer
    # then show a jamfHelper message
    if [[ "$Timer" -gt "0" ]]; then
    echo "${Timer} deferral(s) currently available"
    # Launch jamfHelper
    echo "Launching jamfHelper..."
    jamfHelperAsktoUpgrade
    # Get the value of the jamfHelper, user chosing to upgrade now or defer.
        if [[ "$HELPER" -eq "0" ]]; then
            # User chose to ignore
            echo "${loggedInUser} clicked no"
            CurrTimer=$((Timer-1))
            echo "$CurrTimer" > "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt"
            echo "${CurrTimer} deferral(s) left"
            exit 0
        else
            # User clicked yes
            echo "${loggedInUser} clicked yes"
            # Start the install process
            runInstall
        fi
    fi
fi
# Check the value of the timer variable, if equals 0 then no deferal left run the upgrade
if [[ "$Timer" -eq "0" ]]; then
    echo "No Deferral left, run the install!"
    # Start the install process
    runInstall
fi