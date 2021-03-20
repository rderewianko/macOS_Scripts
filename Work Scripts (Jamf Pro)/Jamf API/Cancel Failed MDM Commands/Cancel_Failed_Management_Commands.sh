#!/bin/zsh

########################################################################
#                 Cancel Failed Management Commands                    #
################ Written by Phil Walker November 2019 ##################
########################################################################
# Edit Nov 2020
# Edit Mar 2021

## API Username & Password
## Note: API account must have READ and UPDATE access to:
## • Computers
## New API privilege Flush MDM Commands is also now required
## This is found under Jamf Pro Server Actions

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted credentials
encryptedUsername="$4" # defined in the policy
encryptedPassword="$5" # defined in the policy
# Jamf Pro URL/JSSResource e.g. https://jamfprourl/JSSResource
jamfProURL="$6" #defined in the policy
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

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

# Decrypt the username and password
apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
# Check for failed Management Commands
failedCommands=$(curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computerhistory/serialnumber/${serialNumber}/subset/Commands" \
| xmllint --xpath '/computer_history/commands/failed' - | grep -i "command")
# If failed commands are found, clear them all
if [[ "$failedCommands" != "" ]]; then
    echo "Failed Management Commands found"
	# Getting the computer ID
	computerID=$(curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computers/serialnumber/$serialNumber" \
    | xmllint --xpath '/computer/general/id/text()' -)
    untilCount="0"
    maxAttempts="5"
    until [[ "$failedCommands" == "" ]] || [[ "$untilCount" -eq "$maxAttempts" ]]; do
        (( untilCount++ ))
        echo "Attempt ${untilCount}: Removing failed Management Commands..."
        # Cancel all failed commands (run the command a maximum of 5 times)
  	    curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/commandflush/computers/id/${computerID}/status/Failed" -X DELETE > /dev/null 2>&1
        sleep 5
        # Re-populate variable
		failedCommands=$(curl -sku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computerhistory/serialnumber/${serialNumber}/subset/Commands" \
        | xmllint --xpath '/computer_history/commands/failed' - | grep -i "command")
    done
    if [[ "$failedCommands" == "" ]]; then
		echo "All failed Management Commands removed"
    else
        echo "Failed commands still found"
        echo "Investigatation required, possible User Approved MDM issue"
        exit 1
    fi
else
	echo "No failed Management Commands found"
fi
exit 0