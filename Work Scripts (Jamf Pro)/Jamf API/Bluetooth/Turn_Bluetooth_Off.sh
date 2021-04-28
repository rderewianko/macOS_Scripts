#!/bin/zsh

########################################################################
#                Turn Bluetooth off using MDM commands                 #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Edit Mar 2021

## API account must have CREATE/READ/UPDATE access to:
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
else
    # Decrypt the username and password
    apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
    apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
    echo "Sending Disable Bluetooth remote command..."
    # Get the computer ID
    computerID=$(curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computers/serialnumber/${serialNumber}" \
    | xmllint --xpath '/computer/general/id/text()' -)
    # Send Disable Bluetooth command
    curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsDisableBluetooth/id/${computerID}" -X POST &>/dev/null
    # Waiting for the command to be actioned and the Bluetooth controller state to change can take several minutes so only check the command was sent
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        echo "Disable Bluetooth remote command sent successfully"
    else
        # Try sending the Disable Bluetooth command again
        curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsDisableBluetooth/id/${computerID}" -X POST &>/dev/null
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Disable Bluetooth remote command sent successfully"
        else
            echo "Failed to send remote command, Bluetooth will remain enabled"
        fi
    fi
fi
exit 0