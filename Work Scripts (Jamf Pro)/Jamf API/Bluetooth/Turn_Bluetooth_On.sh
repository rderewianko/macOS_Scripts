#!/bin/zsh

########################################################################
#                 Turn Bluetooth on using MDM commands                 #
#                       (Self Service policy)                          #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Edit Mar 2021

## API Username & Password
## Jamf Pro Server Objects
## Note: API account must have CREATE/READ/UPDATE access to:
## • Computers
## Jamf Pro Server Actions
## • Send Computer Bluetooth Command

## requires macOS 10.13.4 or later

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted credentials
encryptedUsername="$4" # defined in the policy
encryptedPassword="$5" # defined in the policy
# Jamf Pro URL (https://JamfProURL/JSSResource)
jamfProURL="$6" # defined in the policy
# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# Mac model (friendly name)
macModelFriendly=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Bluetooth controller power status
btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)
# OS product version
productVersion=$(/usr/bin/sw_vers -productVersion)
# Check if the Mac is running Big Sur or later
autoload is-at-least
if is-at-least "11" "$productVersion"; then
    # Jamf helper icon
    helperIcon="/System/Library/PreferencePanes/Bluetooth.prefPane/Contents/Resources/Bluetooth.icns"
else
    osVersion="macOS 10"
    # Jamf helper icon
    helperIcon="/System/Library/PreferencePanes/Bluetooth.prefPane/Contents/Resources/AppIcon.icns"
fi
# Jamf helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf helper title
helperTitle="Message from Bauer IT"
# Jamf helper heading
helperHeading="Bluetooth Turned On"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

function decryptString () 
{
# Decrypt user credentials
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

function menuBarItem ()
{
# Add the item to the menu bar (macOS Catalina or earlier only)
if [[ "$osVersion" == "macOS 10" ]]; then
    echo "${macModelFriendly} running macOS ${productVersion}, adding Bluetooth to the menu bar..."
    runAsUser open '/System/Library/CoreServices/Menu Extras/Bluetooth.menu/'
    echo "Bluetooth status and preferences available in the menu bar"
    helperMenuItem="Status and preferences can be found in the menu bar"
else
    echo "${macModelFriendly} running macOS ${productVersion}, Bluetooth status available in Control Center"
    helperMenuItem="Status and preferences can be found in Control Center"
fi
}

function jamfHelperBTOn ()
{
# Jamf helper to advise users Bluetooth is now on
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -description "Bluetooth has now been turned on ✅

${helperMenuItem}" &
}

########################################################################
#                         Script starts here                           #
########################################################################

# If Bluetooth is already on, advise the user
if [[ "$btPowerStatus" == "1" ]] || [[ "$btPowerStatus" == "true" ]]; then
    echo "Bluetooth already turned on"
    menuBarItem
    jamfHelperBTOn
    sleep 10
    killall -13 "jamfHelper" >/dev/null 2>&1
    exit 0
else
    # Decrypt the username and password
    apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
    apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
    echo "Turning Bluetooth on..."
    # Getting the computer ID
    computerID=$(curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computers/serialnumber/$serialNumber" \
    | xmllint --xpath '/computer/general/id/text()' -)
    # Send Enable Bluetooth command
    curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsEnableBluetooth/id/$computerID" -X POST >/dev/null 2>&1
fi
# Confirm that Bluetooth is now on
until [[ "$btPowerStatus" == "1" ]] || [[ "$btPowerStatus" == "true" ]]; do
    sleep 1
    # Re-populate Bluetooth controller power status variable
    btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)
done
echo "Bluetooth now on"
menuBarItem
jamfHelperBTOn
sleep 10
killall -13 "jamfHelper" >/dev/null 2>&1
exit 0