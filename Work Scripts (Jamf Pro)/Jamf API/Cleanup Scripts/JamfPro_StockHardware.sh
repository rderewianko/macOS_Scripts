#!/bin/bash

########################################################################
#               Delete stock hardware computer records                 #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Edit Mar 2021

## API Username & Password
## Note: API account must have READ access to:
## • Computers
## DELETE access to:
## • Computers

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted credentials
encryptedUsername="Username Encryted String"
encryptedPassword="Password Encryted String"
# Jamf Pro URL
jamfProURL="https://yourjamfprourl/JSSResource/computers"
# Jamf Pro decomission department
decomDept="Your_Stock_Department"
# Temp content
tempDir="/path/to/temp/directory"
# File name
fileName="FileName"
# Date
date=$(date +"%d-%m-%Y")

########################################################################
#                            Functions                                 #
########################################################################

function decryptString () 
{
# Decrypt user credentials
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

function finalizeCSV ()
{
if [[ -f "${tempDir}/${fileName}.txt" ]]; then
    echo "Finalizing csv file..."
    # Use paste to join all data into a final csv file
    paste -s -d'\n' "${tempDir}/${fileName}.txt" >> "${tempDir}/${fileName}.csv"
    # Rename the final csv file with the current date
    mv "${tempDir}/${fileName}.csv" "${tempDir}/${fileName}_${date}.csv"
fi
}

function sendMail ()
{
#Check file size is greater than zero, if so send an email with the file attached
if [[ -s "${tempDir}/${fileName}_${date}.csv" ]]; then
    echo "Sending email with details of deleted records"
    echo "Attached are the stock computers deleted from Jamf Pro" | mailx -r address@domain -s "Jamf Pro stock computers" -a "${tempDir}/${fileName}_${date}.csv" -- address@domain
else
    echo "No computers deleted, no need to send an email"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Decrypt the username and password
apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
# Get the start time
startTime=$(date +"%s")
echo "Script started at: $(date +"%b %d %Y %H:%M:%S")"
echo "Getting all computer ID's..."
# Get all computer ID's
allComputerIDs=$(curl -H "Accept: text/xml" -sfku "${apiUsername}:${apiPassword}" "$jamfProURL" 2>/dev/null | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n)
echo "Checking for computers in the ${decomDept} department..."
echo "-----------------------------------------------------"
while read -r computerID; do
    # Get the computer name
    computerName=$(curl -H "Accept: text/xml" -sfku "${apiUsername}:${apiPassword}" "${jamfProURL}/id/${computerID}" 2>/dev/null | xmllint --format --xpath  "/computer/general/name/text()" - 2>/dev/null)
    # Get the department
    computerDepartment=$(curl -H "Accept: text/xml" -sfku "${apiUsername}:${apiPassword}" "${jamfProURL}/id/${computerID}" | xmllint --format --xpath  "/computer/location/department/text()" - 2>/dev/null)
    if [[ "$computerDepartment" == "$decomDept" ]]; then
        echo "${computerName} has been marked as stock"
        # Export the computer details to a file for reference
        curl -H "Accept: text/xml" -sfku "${apiUsername}:${apiPassword}" "${jamfProURL}/id/${computerID}" 2>/dev/null \
        | xmllint --format --xpath  "/computer/general/name | /computer/general/serial_number | /computer/location/department" - | awk -F'>|<' '{print $3,$7,$11}' >> "${tempDir}/${fileName}.txt"
        # Delete the computer record
        curl -sfku "${apiUsername}:${apiPassword}" "${jamfProURL}/id/${computerID}" -X DELETE &>/dev/null
        echo "Computer record for ${computerName} deleted"
    fi
done < <(echo "$allComputerIDs")
echo "-----------------------------------------------------"
echo "All computer records checked"
# Finalise the CSV
finalizeCSV
# Send an email to a Teams channel/mailbox
sendMail
# Wait before removing the temp file
sleep 2
# Remove the temp file with results
rm -f ${tempDir}/${fileName}*
# Get the end time
endTime=$(date +"%s")
# Work out how long the script took to complete
timeDiff=$((endTime-startTime))
echo "Script completed at: $(date +"%b %d %Y %H:%M:%S"), total run time: ${timeDiff} Seconds"
exit 0
