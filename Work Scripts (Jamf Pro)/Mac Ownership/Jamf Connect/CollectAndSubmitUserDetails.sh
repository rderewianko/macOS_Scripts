#!/bin/zsh

########################################################################
#                   Submit User Details to Jamf Pro                    #
################### written by Phil Walker Dec 2020 ####################
########################################################################
# Edit Feb 2021

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in users username
loggedInUser=$(stat -f %Su /dev/console)
# API creds for connection
apiUser="API_Departments"
apiPass="API_Departments"
# JSS URL
jssUrl=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url 2>/dev/null)
# Hardware UUID
hardwareUUID=$(system_profiler SPHardwareDataType | awk '/UUID/ {print $3}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No one logged in, existing..."
else
    echo "$loggedInUser is logged in"
    if [[ "$loggedInUser" == "admin" ]]; then
        echo "Local admin logged in existing..."
    else
        echo "Not an admin, carry on"
        if [[ -f "/Users/${loggedInUser}/Library/Preferences/com.jamf.connect.state.plist" ]]; then
            # Get Real Name
            userRealName=$(sudo -u "$loggedInUser" defaults read com.jamf.connect.state UserCN 2>/dev/null)
            # Get logged in users email address
            UserEmail=$(sudo -u "$loggedInUser" defaults read com.jamf.connect.state UserEmail 2>/dev/null)
            # Get logged in users position
            userPosition=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | awk '/^JobTitle:/,/^LastName:/' | sed -n 2p | xargs 2>/dev/null)
            # Get logged in users Phone Number
            userPhoneNumber=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | awk '/PhoneNumber:/ {print $2}' 2>/dev/null)
            # Get logged in users Office location
            userOffice=$(dscl "/Active Directory/BAUER-UK/bauer-uk.bauermedia.group" -read /Users/"$loggedInUser" | grep -A1 "physicalDeliveryOfficeName" | sed -n 2p | xargs 2>/dev/null)
            # Check connection to the JSS before submitting ownership details
            jssConnection=$(/usr/local/jamf/bin/jamf checkJSSConnection | tail -1)    

            ### DEBUG
            #echo "loggedInUser:$loggedInUser"
            #echo "-------------"
            #echo "userRealName:$userRealName"
            #echo "UserEmail:$UserEmail"
            #echo "userPosition:$userPosition"
            #echo "userPhoneNumber:$userPhoneNumber"
            #echo "userOffice:$userOffice"
            #echo "jssConnection:$jssConnection"

            if [[ "$jssConnection" == "The JSS is available." ]]; then
                echo "$jssConnection"
                echo "Submitting ownership for account $loggedInUser..."
                # Add the username to the record in Jamf Pro
                if [[ "$loggedInUser" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><username>$loggedInUser</username></location></computer>" >/dev/null 2>&1
                    echo "Username now set to ${loggedInUser} in Jamf Pro"
                fi
                # Add the Full Name to the record in Jamf Pro
                if [[ "$userRealName" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><real_name>$userRealName</real_name></location></computer>" >/dev/null 2>&1
                    echo "Full Name now set to ${userRealName} in Jamf Pro"
                fi
                # Add the Email Address to the record in Jamf Pro
                if [[ "$UserEmail" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><email_address>$UserEmail</email_address></location></computer>" >/dev/null 2>&1
                    echo "Email Address now set to ${UserEmail} in Jamf Pro"
                fi
                # Add the Position to the record in Jamf Pro
                if [[ "$userPosition" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><position>$userPosition</position></location></computer>" >/dev/null 2>&1
                    echo "Position now set to ${userPosition} in Jamf Pro"
                fi
                # Add the Phone Number to the record in Jamf Pro
                if [[ "$userPhoneNumber" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><phone_number>$userPhoneNumber</phone_number></location></computer>" >/dev/null 2>&1
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><phone>$userPhoneNumber</phone></location></computer>" >/dev/null 2>&1
                    echo "Phone Number now set to ${userPhoneNumber} in Jamf Pro"
                fi
                # Add the Office Location to the record in Jamf Pro
                if [[ "$userOffice" != "" ]]; then
                    curl -sku "${apiUser}:${apiPass}" -H "Content-Type: application/xml" "${jssUrl}JSSResource/computers/udid/${hardwareUUID}" \
                    -X PUT -d "<computer><location><room>$userOffice</room></location></computer>" >/dev/null 2>&1
                    echo "Office Location now set to ${userOffice} in Jamf Pro"
                fi
            else
                echo "Can't connect to Jamf Pro URL:${jssUrl}"
            fi
        else
            echo "Jamf Connect state information not found, unable to check user information"
        fi                   
    fi
fi
exit 0