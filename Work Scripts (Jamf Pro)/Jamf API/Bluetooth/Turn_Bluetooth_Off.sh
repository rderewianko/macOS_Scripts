#!/bin/zsh

########################################################################
#                Turn Bluetooth off using MDM commands                 #
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
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# Bluetooth controller power status
btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)

########################################################################
#                            Functions                                 #
########################################################################

function decryptString () 
{
# Decrypt user credentials
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$btPowerStatus" == "0" ]] || [[ "$btPowerStatus" == "false" ]]; then
    echo "Bluetooth already turned off, nothing to do"
    exit 0
else
    # Decrypt the username and password
    apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
    apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
    echo "Turning Bluetooth off..."
    # Getting the computer ID
    computerID=$(curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computers/serialnumber/$serialNumber" \
    | xmllint --xpath '/computer/general/id/text()' -)
    # Send Disable Bluetooth command
    curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsDisableBluetooth/id/$computerID" -X POST >/dev/null 2>&1
fi
# Confirm that Bluetooth is now off
until [[ "$btPowerStatus" == "0" ]] || [[ "$btPowerStatus" == "false" ]]; do
    sleep 1
    # Re-populate Bluetooth controller power status variable
    btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)
done
echo "Bluetooth now off"
exit 0