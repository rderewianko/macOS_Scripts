#!/bin/zsh

########################################################################
#                   Submit User Details to Jamf Pro                    #
################### written by Phil Walker Dec 2020 ####################
########################################################################
# Edit June 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Encrypted credentials
encryptedAPIUsername="$4"
encryptedAPIPassword="$5"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in users username
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Jamf Pro URL
jamfProURL=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url 2>/dev/null)
# Hardware UUID
hardwareUUID=$(system_profiler SPHardwareDataType | awk '/UUID/ {print $3}')
# Check connection to Jamf Pro
jssConnection=$(/usr/local/jamf/bin/jamf checkJSSConnection | tail -1)

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

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No one logged in, existing..."
else
    echo "${loggedInUser} is logged in"
    if [[ "$loggedInUser" == "admin" ]]; then
        echo "Local admin logged in existing..."
        exit 0
    else
        echo "Not an admin, carry on"
        if [[ "$jssConnection" == "The JSS is available." ]]; then
            # Decrypt the username and password
            apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
            apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
            echo "Submitting ownership for account ${loggedInUser}..."
            if [[ -f "/Users/${loggedInUser}/Library/Preferences/com.jamf.connect.state.plist" ]]; then
                # Get Real Name
                userRealName=$(runAsUser defaults read com.jamf.connect.state UserCN 2>/dev/null)
                # Get logged in users email address
                UserEmail=$(runAsUser defaults read com.jamf.connect.state UserEmail 2>/dev/null)
                # Get logged in users position
                userPosition=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | awk '/^JobTitle:/,/^LastName:/' | sed -n 2p | xargs 2>/dev/null)
                # Get logged in users Phone Number
                userPhoneNumber=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | awk '/PhoneNumber:/ {print $2}' 2>/dev/null)
                # Get logged in users Office location
                userOffice=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | grep -A1 "physicalDeliveryOfficeName" | sed -n 2p | xargs 2>/dev/null) 

                ### DEBUG
                #echo "loggedInUser:$loggedInUser"
                #echo "-------------"
                #echo "userRealName:$userRealName"
                #echo "UserEmail:$UserEmail"
                #echo "userPosition:$userPosition"
                #echo "userPhoneNumber:$userPhoneNumber"
                #echo "userOffice:$userOffice"
                #echo "jssConnection:$jssConnection"

                # Add the username to the record in Jamf Pro
                if [[ "$loggedInUser" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><username>$loggedInUser</username></location></computer>" &>/dev/null
                    echo "Username now set to ${loggedInUser} in Jamf Pro"
                fi
                # Add the Full Name to the record in Jamf Pro
                if [[ "$userRealName" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><real_name>$userRealName</real_name></location></computer>" &>/dev/null
                    echo "Full Name now set to ${userRealName} in Jamf Pro"
                fi
                # Add the Email Address to the record in Jamf Pro
                if [[ "$UserEmail" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><email_address>$UserEmail</email_address></location></computer>" &>/dev/null
                    echo "Email Address now set to ${UserEmail} in Jamf Pro"
                fi
                # Add the Position to the record in Jamf Pro
                if [[ "$userPosition" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><position>$userPosition</position></location></computer>" &>/dev/null
                    echo "Position now set to ${userPosition} in Jamf Pro"
                fi
                # Add the Phone Number to the record in Jamf Pro
                if [[ "$userPhoneNumber" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><phone_number>$userPhoneNumber</phone_number></location></computer>" &>/dev/null
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><phone>$userPhoneNumber</phone></location></computer>" &>/dev/null
                    echo "Phone Number now set to ${userPhoneNumber} in Jamf Pro"
                fi
                # Add the Office Location to the record in Jamf Pro
                if [[ "$userOffice" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><room>$userOffice</room></location></computer>" &>/dev/null
                    echo "Office Location now set to ${userOffice} in Jamf Pro"
                fi
            else   
                # Add the username to the record in Jamf Pro
                if [[ "$loggedInUser" != "" ]]; then
                    curl -sku "${apiUsername}:${apiPassword}" -H "Content-Type: application/xml" "${jamfProURL}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><username>$loggedInUser</username></location></computer>" &>/dev/null
                    echo "Username now set to ${loggedInUser} in Jamf Pro"
                fi
            fi
        else
            echo "Can't connect to Jamf Pro URL: ${jamfProURL}"
        fi
    fi
fi
exit 0