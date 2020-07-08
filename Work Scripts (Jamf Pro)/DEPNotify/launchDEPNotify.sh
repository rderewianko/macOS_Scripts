#!/bin/bash

########################################################################
#            Launch DEPNotify and complete Mac setup process           #
############# Written by Ben Carter & Phil Walker Sept 2019 ############
########################################################################
# Edit July 2020

########################################################################
#                            Variables                                 #
########################################################################

# Get the Hostname
hostName=$(scutil --get HostName)
# Variables for the AD bind
theUser="YourADBindUsername"	 # Username for AD bind account
thePass="YourADBindPassword"	 # password for the AD account
theDomain="YourDomain"         # AD forest for bind
# Hardware model
hwModel=$(sysctl -n hw.model)
if [[ "$hwModel" =~ "MacBook" ]]; then
    macModel="Laptop"
else
    macModel="Desktop"
fi
# Set the OU based on model for the computer record to be added into
theOU="OU=$macModel,OU=Macs,OU=uk,OU=company,DC=company-uk,DC=company,DC=group"
# API creds for connection
apiUser="APIUser"
apiPass="APIUserPassword"
# JSS URL
jssUrl=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
# Hardware UUID
hardwareUUID=$(/usr/sbin/ioreg -d2 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $(NF-1)}')

########################################################################
#                            Functions                                 #
########################################################################

function DEPNotifyGraphics ()
{
#Go get the Company icon from Company Homepage website
echo "Getting Company logo for DEPNotify"
curl -s --url https://www.bauermedia.com/fileadmin/site/img/logo_header.png > /var/tmp/bauer_logo.png
}

function DEPNotifyLogFile ()
{
# Create the depnotify log file
echo "Creating DEPNotify log file"
/usr/bin/touch /var/tmp/depnotify.log
/bin/chmod 777 /var/tmp/depnotify.log
}

function DEPNotifySetupRegistration ()
{
# Setup Registration window
echo "Creating Registration screen"
/usr/bin/defaults write menu.nomad.DEPNotify RegisterMainTitle -string "Registration"
/usr/bin/defaults write menu.nomad.DEPNotify registrationPicturePath "/Path/to/picture.jpg"
/usr/bin/defaults write menu.nomad.DEPNotify RegisterButtonLabel -string "Get Started"
/usr/bin/defaults write menu.nomad.DEPNotify textField1Label "Asset Number"
/usr/bin/defaults write menu.nomad.DEPNotify textField1Placeholder "e.g 12345"
/usr/bin/defaults write menu.nomad.DEPNotify TextField1CharValidation '1234567890' #Only allow numerical input to text boxes
/usr/bin/defaults write menu.nomad.DEPNotify textField1Bubble -array "Asset Information" "Please provide the correct asset number from the Company asset sticker on your Mac. Only enter numbers."
/usr/bin/defaults write menu.nomad.DEPNotify textField1IsOptional -bool false
/usr/bin/defaults write menu.nomad.DEPNotify popupButton1Label -string 'Department'
/usr/bin/defaults write menu.nomad.DEPNotify popupMenu1Bubble -array "Department" "Please select the most relevent department that you work in"
# Read Building and Department from JSS into DEP Notify config
IFS=$'\n'
depts=($(curl -s -k -u ${apiUser}:${apiPass} -H "accept: text/xml" ${jssUrl}JSSResource/departments -X GET | xmllint --format - | /usr/bin/grep "<name>" | /usr/bin/sed "s/<name>//g;s/<\/name>//g;s/    //g" ))
/usr/bin/defaults write menu.nomad.DEPNotify popupButton1Content -array $( for((i=0;i<${#depts[@]};i++)); do /bin/echo "${depts[$i]}"; done )
unset $IFS
}

function DEPNotifySetup ()
{
# Set up the initial DEP Notify window
echo "Creating DEPNotify start screen"
/bin/echo "Command: Image: /var/tmp/company_logo.png" >> /var/tmp/depnotify.log
/bin/echo "Command: WindowStyle: NotMovable" >> /var/tmp/depnotify.log
/bin/echo "Command: WindowTitle: Your Company Name" >> /var/tmp/depnotify.log
/bin/echo "Command: MainTitle: Welcome to your new Mac" >> /var/tmp/depnotify.log
/bin/echo "Command: Determinate: 65" >> /var/tmp/depnotify.log
}

function updateComputerName ()
{
echo "Updating Mac computer name..."
/usr/sbin/scutil --set ComputerName "${wksComputerName}"
/usr/sbin/scutil --set LocalHostName "${wksComputerName}"
/usr/sbin/scutil --set HostName "${wksComputerName}"
dscacheutil -flushcache
sleep 3
# Get the Hostname
hostName=$(scutil --get HostName)
echo "scutil now reporting Hostname as : $hostName"
}

function rebindtoAD ()
{
# First check if we can get to AD
domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
if [[ "$domainPing" == "" ]]; then
    echo "$theDomain is not reachable"
    /bin/echo "Status: Company domain not reachable, unable to bind to Active Directory" >> /var/tmp/depnotify.log
    /bin/sleep 3
    # Add the computer name to the asset tag field in the JSS
    echo "Update Asset Tag in JSS"
    /bin/echo "Status: Saving Computer Name..." >> /var/tmp/depnotify.log
    /usr/local/jamf/bin/jamf recon -assetTag "$hostName"
else
  	echo "$theDomain is reachable"
    # Unbind the Mac - remove the AD record
    echo "Unbind from company Domain"
    dsconfigad -remove -u "$theUser" -p "$thePass"
    echo "Attempt binding to Company Name"
    # Bind the Mac using the new hostname and OU
    /usr/local/jamf/bin/jamf bind -type ad -domain "$theDomain" -computerID "$hostName" -username "$theUser" -password "$thePass" -ou "$theOU" -cache -defaultShell /bin/bash -localHomes
    # Add the computer name to the asset tag field in the JSS
    echo "Update Asset Tag in JSS"
    /bin/echo "Status: Saving Computer Name..." >> /var/tmp/depnotify.log
    /usr/local/jamf/bin/jamf recon -assetTag "$hostName"
fi
}

function addPolicyToStartup ()
{
# Check if the custom trigger to cancel failed commands has already been added to the startup script - the startup script gets overwritten during a jamf manage.
jamfCancelFailed=$(grep "/usr/local/jamf/bin/jamf policy -event cancel_failed_commands" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
if [[ -n "$jamfCancelFailed" ]]; then
    echo "cancel_failed_commands policy already entered in startup script"
else
    # Add cancel_failed_commands policy to the startup script
    echo "cancel_failed_commands policy not found in startup script adding..."
    # Remove the exit from the file
    sed -i '' "/$exit 0/d" /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
    # Add in additional custom policy line with an exit in
    /bin/echo "## Run policy to clear failed management commands" >> /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
    /bin/echo "/usr/local/jamf/bin/jamf policy -event cancel_failed_commands" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
    /bin/echo "exit 0" >>  /Library/Application\ Support/JAMF/ManagementFrameworkScripts/StartupScript.sh
    # Re-populate variable
    jamfCancelFailed=$(grep "/usr/local/jamf/bin/jamf policy -event cancel_failed_commands" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    if [[ -n "$jamfCancelFailed" ]]; then
        echo "cancel_failed_commands policy added to the startup script successfully"
    else
        echo "cancel_failed_commands policy NOT added to the startup script"
    fi
fi
}

function cleanup ()
{
# All done! Quit DEPNotify, delete temporary files and restart.
# Remove temp files

# Check for and delete the menu.nomad.DEPNotify.plist
if [ -f "/var/root/Library/Preferences/menu.nomad.DEPNotify.plist" ]; then
    echo "Found DEPNotify preference for $loggedInUser, deleting"
    /bin/rm /var/root/Library/Preferences/menu.nomad.DEPNotify.plist
    if [ -f "/var/root/Library/Preferences/menu.nomad.DEPNotify.plist" ]; then
        echo "Error file deletion failed"
    else
        echo "menu.nomad.DEPNotify.plist Successfully Deleted"
    fi
else
    echo "Error cannot find DEPNotify preference for $loggedInUser"
fi

# Check for and delete the depnotify.log
if [ -f "/var/tmp/depnotify.log" ]; then
    echo "Found depnotify.log, deleting...."
    /bin/rm /var/tmp/depnotify.log
    if [ -f "/var/tmp/depnotify.log" ]; then
        echo "Error file deletion failed"
    else
        echo "depnotify.log deleted"
    fi
else
    echo "Error cannot find depnotify.log"
fi

# Check for and delete the UserInput.plist
if [ -f "/Users/Shared/UserInput.plist" ]; then
    echo "Found UserInput.plist, deleting"
    /bin/rm /Users/Shared/UserInput.plist
    if [ -f "/Users/Shared/UserInput.plist" ]; then
        echo "Error file deletion failed"
    else
        echo "UserInput.plist Deleted"
    fi
else
    echo "Error cannot find UserInput.plist"
fi

# Check for and delete the com.depnotify.provisioning.restart BOM
if [ -f "/var/tmp/com.depnotify.provisioning.restart" ]; then
    echo "Found ccom.depnotify.provisioning.restart, Deleting...."
    /bin/rm /var/tmp/com.depnotify.provisioning.restart
    if [ -f "/var/tmp/com.depnotify.provisioning.restart" ]; then
        echo "Error file deletion failed"
    else
        echo "com.depnotify.provisioning.restart Deleted"
    fi
else
    echo "Error cannot find com.depnotify.provisioning.restart"
fi

# Re-enable Jamf check-in
echo "Enabling Jamf Pro LaunchDaemons"
/bin/launchctl load -w /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
# Disable caffinate.
echo "Disable caffinate"
/bin/kill "$caffeinatePID"

# Delete the DEPNotify application
rm -r "$depLoc"
 #Delete the Company logo used for depnotify
  rm /var/tmp/company.png
# Delete this script
rm "$0"
# Reboot to finalise
shutdown -r now
exit 0
}

########################################################################
#                         Script starts here                           #
########################################################################

# Before we start to run DEPNotify check a few things
# Check Setup Assistant has finished before continuing
setupAssistantProcess=$(pgrep -l "Setup Assistant")
until [ "$setupAssistantProcess" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $setupAssistantProcess."
    sleep 1
    setupAssistantProcess=$(pgrep -l "Setup Assistant")
done
echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant finished"

# Checking to see if Finder is running before continuing. This can help
# in scenarios where an end user is not configuring the device.
finderProcess=$(pgrep -l "Finder")
until [ "$finderProcess" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen."
    sleep 1
    finderProcess=$(pgrep -l "Finder")
done
echo "$(date "+%a %h %d %H:%M:%S"): Finder process found."

# Now setup Assistant has finished we can get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
userID=$(/usr/bin/id -u $loggedInUser)
echo "$loggedInUser is logged in and had an ID of $userID"

# Check that the /var/tmp/com.depnotify.provisioning.done file is not present.
# This prevents DEPNotify from running again.
if [ -f "/var/tmp/com.depnotify.registration.done" ]; then
    echo "DEPNotify has already been run, exiting..."
    exit 0
else
    # Setup the registration window for DEPNotify
    DEPNotifySetupRegistration
    # Get graphics for DEPNotify Window
    DEPNotifyGraphics
    # Setup the DEPNotify log
    DEPNotifyLogFile
    # Setup the first window for DEPNotify
    DEPNotifySetup
    # Add cancel failed commands policy to the startup script
    addPolicyToStartup

    # Caffeinate the mac!
    /usr/bin/caffeinate -d -i -m -u &
    caffeinatePID=$!

    # Disable Jamf Check-In so nothing conflicts or stops DEPNotify from calling Jamf Pro policies
    /bin/launchctl unload -w /Library/LaunchDaemons/com.jamfsoftware.task.1.plist

    ##############################################
    # LETS GO! Load DEP Notify
    ##############################################
    depLoc=$(/usr/bin/find /var/tmp -maxdepth 2 -type d -iname "*DEP*.app")
    /bin/launchctl asuser $userID "$depLoc/Contents/MacOS/DEPNotify" -jamf -fullScreen &
    depPID=$!

    # Prompt for registration info
    /bin/echo "Command: Image: /var/tmp/company_logo.png" >> /var/tmp/depnotify.log
    /bin/echo "Command: MainTitle: Welcome to your new Mac." >> /var/tmp/depnotify.log
    /bin/echo "Command: MainText: On the next screen you will be asked to input some information about this Mac. \n\nPlease ensure that the correct information is provided as false information can cause your Mac to not work correctly." >> /var/tmp/depnotify.log
    /bin/echo "Command: ContinueButtonRegister: Continue" >> /var/tmp/depnotify.log
    /bin/echo "Status: Waiting for Device Configuration Information" >> /var/tmp/depnotify.log

    # Check for Registration info - wait untill entered
    until [ -f /var/tmp/com.depnotify.registration.done ]; do
        /bin/echo "Status: Click the Continue button..." >> /var/tmp/depnotify.log
        /bin/sleep 5
        /bin/echo "Waiting for Device Configuration Information" >> /var/tmp/depnotify.log
    done

    # Now registration information has been provided show a loading screen as the bind can take time.
    /bin/echo "Status: Saving....." >> /var/tmp/depnotify.log
    /bin/echo "Command: Image: /var/tmp/company_logo.png" >> /var/tmp/depnotify.log
    /bin/echo "Command: MainTitle: Saving Registration Details." >> /var/tmp/depnotify.log
    /bin/echo "Command: MainText: Thank you for providing the details about this Mac.\n\nSoftware will be installed shortly.\n\n" >> /var/tmp/depnotify.log

    # Get info we just recorded and process it
    assetNumber=$(/usr/bin/defaults read /Users/Shared/UserInput.plist "Asset Number")
    department=$(/usr/bin/defaults read /Users/Shared/UserInput.plist Department )
    # Add WKS to the asset number entered
    echo "Asset Number Provided : $assetNumber"
    wksComputerName="WKS${assetNumber}"
    echo "New Computer name will be ${wksComputerName}"
    # Update computer name
    /bin/echo "Status: Setting Computer Name to ${wksComputerName}..." >> /var/tmp/depnotify.log
    updateComputerName
    # Bind to AD and update Jamf Pro - Checks if AD is available in the function
    /bin/echo "Status: Joining ${wksComputerName} to the company domain....." >> /var/tmp/depnotify.log
    rebindtoAD
    # Send selected department to Jamf Pro
    /bin/echo "Status: Saving Department....." >> /var/tmp/depnotify.log
    /usr/bin/curl -s -k "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" -u "${apiUser}:${apiPass}" -H "Content-Type: text/xml" -X PUT -d "<computer><location><department>$department</department></location></computer>"
    /bin/sleep 2

    # Start the software deployment
    /bin/echo "Command: Image: /var/tmp/bauer_logo.png" >> /var/tmp/depnotify.log
    /bin/echo "Command: MainTitle: Software Installations." >> /var/tmp/depnotify.log
    /bin/echo "Status: Installing Software..." >> /var/tmp/depnotify.log
    /bin/echo "Command: MainText: This process can take 10-20 minutes to complete.\n\nPlease do not turn this Mac off." >> /var/tmp/depnotify.log
    /usr/local/jamf/bin/jamf policy -event remove_temp_fv_admin
    /usr/local/jamf/bin/jamf policy -event remove_non_vpp_apps
    /usr/local/jamf/bin/jamf policy
    /bin/sleep 3

    # Run a Recon
    /bin/echo "Status: Updating Inventory" >> /var/tmp/depnotify.log
    /bin/echo "Command: MainText: Performing an inventory update of the device. Please wait." >> /var/tmp/depnotify.log
    /usr/local/jamf/bin/jamf recon
    /bin/sleep 3

    # Submitting information screen
    /bin/echo "Status: Waiting for a restart....." >> /var/tmp/depnotify.log
    /bin/echo "Command: Image: /var/tmp/bauer_logo.png" >> /var/tmp/depnotify.log
    /bin/echo "Command: MainTitle: Mac Setup Complete." >> /var/tmp/depnotify.log
    /bin/echo "Command: MainText: Rebooting to finish.\n\nEnjoy your Mac.\n\n❤️IT." >> /var/tmp/depnotify.log
    /bin/sleep 7
    # Run the cleanup function
    cleanup
    exit 0
fi
