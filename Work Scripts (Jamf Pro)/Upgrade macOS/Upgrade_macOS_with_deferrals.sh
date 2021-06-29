#!/bin/zsh

########################################################################
#                 Upgrade macOS with user deferrals                    #
################# Written by Phil Walker August 2019 ###################
########################################################################
# Edit July 2020
# Edit Mar 2021

# Installer to be deployed separately

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# macOS installer path
osInstallerLocation="$4"
# Required disk space (GB)
requiredSpace="$5"
# OS name for jamfHelper windows
osName="$6"
# Policy name for deferral file
policyName="$7"
# Deferral limit in days
deferralLimit="$8"
# Helper timeout (seconds) e.g. 14400 for 4 hours
helperTimeout="$9"

##DEBUG
#osInstallerLocation="/Applications/Install macOS Catalina.app"
#requiredSpace="15"
#osName="macOS Catalina"
#policyName="macOSCatalinaUpgrade" #Policy name for deferral file.
#deferralLimit="3" #Deferral limit in days
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Mac model
macModel=$(sysctl -n hw.model)
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name://' | xargs)
# OS Version
osVersion=$(sw_vers -productVersion)
# Check the logged in user has a local account
mobileAccount=$(dscl . -read /Users/"$loggedInUser" OriginalNodeName 2>/dev/null)
# Check we have the timer file and if not create it and populate with the number of permitted deferrals
if [[ ! -e "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt" ]]; then
    echo "$deferralLimit" > "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt"
fi
# Get the value of the timer file and store for later
deferralFile=$(cat "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt")
# Jamf Helper variables
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Icons
helperIconOSIcon="${osInstallerLocation}/Contents/Resources/ProductPageIcon.icns"
helperIconOSInstall="${osInstallerLocation}/Contents/Resources/InstallAssistant.icns"
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Title
helperTitle="Message From Bauer Technology"
# Heading
helperHeading="An important upgrade is availabe for your Mac - ${deferralFile} deferral(s) remaining"
# Description
helperDescription="The ${osName} upgrade includes new features, security updates and performance enhancements.

Would you like to upgrade now? You may choose not to upgrade to ${osName} now, but after ${deferralFile} deferrals your mac will be automatically upgraded.

During this upgrade, you will not have access to your computer! The upgrade can take up to 1 hour to complete.

If using a laptop please make sure you are connected to power.

You must ensure all work is saved before clicking the 'Upgrade Now' button. All of your files and Applications will remain exactly as you leave them.

You can also trigger the upgrade via the Self Service Application at any time e.g. over lunch or just before you leave for the day.

                                                                                                                                    "

########################################################################
#                            Functions                                 #
########################################################################

function helperAsktoUpgrade ()
{
HELPER=$( "$jamfHelper" -windowType utility -icon "$helperIconOSIcon" -title "$helperTitle" -alignHeading center \
-heading "$helperHeading" -description "$helperDescription" -timeout "$helperTimeout" -countdown -alignCountdown center \
-button1 "Later" -button2 "Upgrade Now" -defaultButton "2" )
}

function helperUpdateConfirm ()
{
# Show a message via Jamf Helper that the update is ready, this is after it has been deferred
"$jamfHelper" -windowType utility -icon "$helperIconOSInstall" -title "$helperTitle" -heading "    ${osName} upgrade is now ready to be installed     " \
-description "This upgrade includes new features, security updates and performance enhancements.

Your Mac will restart once complete!

Please save all of your work before clicking install" -timeout "$helperTimeout" -countdown -alignCountdown center -button1 "Install" -defaultButton "1"
}

function helperInProgress ()
{
"$jamfHelper" -windowType utility -icon "$helperIconOSInstall" -title "$helperTitle" -heading "Please wait as we prepare your computer for ${osName}..." \
-description "This process will take approximately 5-10 minutes. Please do not open any documents or applications.
Once completed your computer will reboot and begin the upgrade.

During this upgrade you will not have access to your Mac!
It can take up to 60 minutes to complete the upgrade process.
Time for a ☕️ ...

" &
}

function helperNoPower ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "No power found - upgrade cannot continue!" \
-description "Please connect a power cable and try again." -button1 "Retry" -defaultButton 1
}

function helperMobileAccount ()
{
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Mobile account detected - upgrade cannot continue!" \
-description "To resolve this issue a logout/login is required.

In 30 seconds you will be automatically logged out of your current session.
Please log back in to your Mac, launch the Self Service app and run the ${osName} upgrade again.

If you have any further issues please contact the IT Service Desk on 0345 058 4444." -timeout 30 -button1 "Logout" -defaultButton 1
}

function helperNoSpace ()
{
helperSpace=$(
"$jamfHelper" -windowType utility -icon "$helperIconProblem" -title "$helperTitle" -heading "Not enough free space found - upgrade cannot continue!" \
-description "Please ensure you have at least ${requiredSpace}GB of free space
Available Space : ${freeSpace}GB

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
pwrAdapter=$(pmset -g ps)
batteryPercentage=$(pmset -g ps | awk '/InternalBattery/{print $3}' | sed 's/%//g; s/;//g')
if [[ "$pwrAdapter" =~ "AC Power" ]] || [[ "$batteryPercentage" -ge "90" ]]; then
    pwrStatus="OK"
	echo "Power Check: OK - AC Power or above 90% battery detected"
else
	pwrStatus="ERROR"
	echo "Power Check: ERROR - AC Power not detected"
fi
}

function checkSpace ()
{
# Check disk space
freeSpace=$(diskutil info / | grep "Free Space" | awk '{print $4}')
if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
	echo "Disk Check: OK - ${freeSpace%.*}GB of free space detected"
else
	spaceStatus="ERROR"
	echo "Disk Check: ERROR - ${freeSpace%.*}GB of free space detected"
fi
}

function checkAccountStatus ()
{
# Check FileVault and account status
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    fileVaultStatus=$(fdesetup status | awk '/FileVault is/{print $3}' | tr -d .)
    if [[ "$fileVaultStatus" == "Off" ]]; then
        echo "FileVault off, skipping user account checks"
    else
        echo "FileVault is on, checking that all FileVault enabled users have local accounts..."
        allUsers=$(dscl . -list /Users | grep -v "^_\|casadmin\|daemon\|nobody\|root\|admin\|jamfcloudadmin")
        for user in $allUsers; do
            fileVaultUser=$(fdesetup list | grep "$user" | awk  -F, '{print $1}')
            if [[ "$fileVaultUser" == "$user" ]]; then
                fvMobileAccount=$(dscl . -read /Users/"$user" OriginalNodeName 2>/dev/null)
                if [[ "$fvMobileAccount" == "" ]]; then
                    echo "${user} is a FileVault enabled user with a local account"
                else
                    echo "${user} is a FileVault enabled user with a mobile account, aborting upgrade!"
                    echo "Please contact ${user} and ask them to login to demobilise their account before attempting the upgrade again"
                    exit 1
                fi
            fi
        done
    fi
else
    echo "Confirming that ${loggedInUser} has a local account..."
    if [[ "$mobileAccount" == "" ]]; then
        echo "${loggedInUser} has a local account"
    else
        echo "${loggedInUser} has a mobile account, aborting OS upgrade"
        echo "Advising ${loggedInUser} via a jamfHelper that they will be logged out in 30 seconds as a logout/login is required"
        helperMobileAccount
        echo "Returning to the login window to demobilise the account on next login..."
        killall -HUP loginwindow
        exit 1
    fi
fi
}

function runInstall ()
{
# Check users have local accounts
checkAccountStatus
# Check power status for MacBooks only
if [[ "$macModel" =~ "MacBook" ]]; then
    checkPower
    until [[ "$pwrStatus" == "OK" ]]; do
        echo "No Power"
        helperNoPower
        sleep 5
        checkPower
    done
fi
# Check the Mac meets the space requirements
checkSpace
until [[ "$spaceStatus" == "OK" ]]; do
    echo "Not enough disk space"
    helperNoSpace
    if [[ "$helperSpace" == "2" ]]; then
        echo "User clicked quit at lack of space message"
        exit 1
    fi
    sleep 5
    checkSpace
done
echo "Ask for final agreement to upgrade"
helperUpdateConfirm
# All checks passed, start the upgrade
echo "--------------------------"
echo "All checks passed"
echo "--------------------------"
# Quit all open Apps
echo "Closing all Microsoft Apps..."
microsftApps=( "Microsoft\ Edge" "Microsoft\ Excel" "Microsoft\ OneNote" "Microsoft\ Outlook" \
"Microsoft\ PowerPoint" "Microsoft\ Remote\ Desktop" "Microsoft\ Word" )
for app in ${(Q)${(z)microsftApps}}; do
    pkill -HUP "$app" >/dev/null 2>&1
done
# Forcing close any remaining Microsoft apps
pkill -f "Microsoft"
echo "Closing all other open applications..."
killall -u "$loggedInUser" >/dev/null 2>&1
# Launch jamfHelper
echo "Launching jamfHelper..."
helperInProgress
# Begin Upgrade
addReconOnBoot
echo "Launching startosinstall..."
"$osInstallerLocation"/Contents/Resources/startosinstall --agreetolicense --nointeraction
exit 0
}

########################################################################
#                         Script starts here                           #
########################################################################

# Clear any jamfHelper windows
killall -13 "jamfHelper" >/dev/null 2>&1
echo "${macModelFull} running ${osVersion}, starting upgrade to ${osName}"
echo "Free space required: ${requiredSpace} GB"
# Check the installer is downloaded if it's not there exit
if [[ ! -d "$osInstallerLocation" ]]; then
    echo "${osName} installer not found!"
    echo "Check available disk space and the result of the policy to install ${osName}"
    exit 1
else
    echo "${osName} installer found: ${osInstallerLocation}"
fi
# Installer found, check to see if a user is logged in
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
    # Show status of user accounts, power and space for reporting. As no user is logged in no action can be taken to fix any issues.
    checkAccountStatus
    if [[ "$macModel" =~ "MacBook" ]]; then
        checkPower
    fi
    checkSpace
    # All checks passed, start the upgrade
    echo "--------------------------"
    echo "All checks passed"
    echo "--------------------------"
    addReconOnBoot
    echo "Launching startosinstall..."
    "$osInstallerLocation"/Contents/Resources/startosinstall --nointeraction --agreetolicense
    exit 0
else
    echo "Logged in user: ${loggedInUser}"
    # Check the value of the timer variable, if greater than 0 i.e. can defer
    # then show a jamfHelper message
    if [[ "$deferralFile" -gt "0" ]]; then
        echo "${deferralFile} deferral(s) currently available"
        # Launch jamfHelper
        echo "Launching jamfHelper..."
        jamfHelperAsktoUpgrade
        # Get the value of the jamfHelper, user chosing to upgrade now or defer.
        if [[ "$HELPER" -eq "0" ]]; then
            # User chose to ignore
            echo "${loggedInUser} clicked no"
            currentTimer=$((deferralFile-1))
            echo "$currentTimer" > "/Library/Application Support/JAMF/.UpgradeDeferral-${policyName}.txt"
            echo "${currentTimer} deferral(s) left"
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
if [[ "$deferralFile" -eq "0" ]]; then
    echo "No Deferral left, run the install!"
    # Start the install process
    runInstall
fi