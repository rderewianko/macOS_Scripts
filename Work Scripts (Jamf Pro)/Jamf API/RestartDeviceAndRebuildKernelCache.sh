#!/bin/zsh

########################################################################
#                 Restart And Rebuild Kernel Cache                     #
################## Written by Phil Walker July 2021 ####################
########################################################################

## API account must have READ access to:
## • Computers
## Jamf Pro Server Actions
## • Send Mobile Device Restart Device Command
## • View MDM command information in Jamf Pro API

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Encrypted credentials
encryptedAPIUsername="U2FsdGVkX1/rGOgjSIDlkrq3op5LNoxONdwLfnMKctc47NdVDbdz7TNbk7SuShxe" # defined in the policy
encryptedAPIPassword="U2FsdGVkX18DoVF8RQ2skZBXjQAlSvzy9/nCltxVx45BLkMwFFl9t6RiaFUng0zy" # defined in the policy
# Jamf Pro URL
jamfProURL="https://bauermediagroup.jamfcloud.com" # defined in the policy
############ Variables for Jamf Pro Parameters - End ###################

# Serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon
helperIcon="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/Resources/Restart.png"
# Helper title
helperTitle="Message from Bauer Technology"

########################################################################
#                            Functions                                 #
########################################################################

function decryptString () 
{
# Decrypt user credentials
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

function jamfHelperRestart ()
{
# Restarting helper
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Restarting your Mac to complete the installation..." -alignDescription natural &
}


########################################################################
#                         Script starts here                           #
########################################################################

# Kill Self Service so that it doesn't open again after the restart
pkill "Self Service"
# Jamf Helper to advise of the restart
jamfHelperRestart
# Decrypt the username and password
apiUsername=$(decryptString "$encryptedAPIUsername" 'eb18e8234880e592' '7cafbabd1a820642169c2785')
apiPassword=$(decryptString "$encryptedAPIPassword" '03a1517c450dac91' 'ec3d487180a37ab671f872dd')
# create base64-encoded credentials
encodedCredentials=$(printf "$apiUsername:$apiPassword" | iconv -t ISO-8859-1 | base64 -i -)
# generate an authorization bearer token
authToken=$(curl "$jamfProURL/uapi/auth/tokens" --silent --request POST --header "Authorization: Basic $encodedCredentials")
# Clean up token to omit expiration details
tokenFinal=$(awk -F \" '{print $4}' <<< "$authToken" | xargs)
# Device management ID
managementID=$(curl --silent -X GET "$jamfProURL/uapi/preview/computers?size=2000" -H "accept: application/json" --header "Authorization: Bearer $tokenFinal" \
| awk '/'$serialNumber'/ {p=1; next} /isManaged/ {p=0} {if (p==1) print $0}' | grep 'managementId' | awk '{ print $3}' | sed 's/[,"]//g')
# Wait for the installer to finish
sleep 30
# Restart the device
curl "$jamfProURL/api/preview/mdm/commands" --silent  \
--request POST \
--header "Authorization: Bearer $tokenFinal" \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data-raw '{
    "clientData": [
        {
            "managementId": "'$managementID'",
            "clientType": "COMPUTER"
        }
    ],
    "commandData": {
        "commandType": "RESTART_DEVICE",
        "rebuildKernelCache": "true"
    }
}' &>/dev/null
commandResult="$?"
if [[ "$commandResult" == "0" ]]; then
    echo "RestartDevice command successfully sent"
    echo "This Mac will now restart and the Kernel Cache will be rebuilt"
    # Expire our authorisation token
    curl --silent "$jamfProURL/uapi/auth/invalidateToken" --silent --request POST --header "Authorization: Bearer $tokenFinal"
else
    echo "Failed to send RestartDevice command!"
    # Expire our authorisation token
    curl --silent "$jamfProURL/uapi/auth/invalidateToken" --silent --request POST --header "Authorization: Bearer $tokenFinal"
    # Kill the restart helper
    killall -13 "jamfHelper" &>/dev/null
    exit 1
fi
exit 0