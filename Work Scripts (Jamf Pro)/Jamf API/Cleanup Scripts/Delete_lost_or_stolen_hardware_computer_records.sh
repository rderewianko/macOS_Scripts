#!/bin/bash

########################################################################
#           Delete lost or stolen hardware computer records            #
################## Written by Phil Walker July 2019 ####################
########################################################################

## API Username & Password
## Note: API account must have READ access to:
## • Computers
## DELETE access to:
## • Computers

########################################################################
#                            Variables                                 #
########################################################################

#API creds for connection
apiuser="API_User"
apipass="API_Password"

#JSS URL (Leave off trailing slash)
jssurl="https://yourjamfprourl"

#Jamf Pro Lost or Stolen department
lostDept="YourLostorStolenDepartment"

#Date
date=$(date +"%d-%m-%Y")

########################################################################
#                            Functions                                 #
########################################################################

function finalizeCSV ()
{

if [[ -f "/var/tmp/Lost_or_Stolen_Computers.txt" ]]; then
  echo -e "Finalizing csv file...\n"

  #Use paste to join all data into a final csv file
  paste -s -d'\n' "/var/tmp/Lost_or_Stolen_Computers.txt" >> "/var/tmp/Lost_or_Stolen_Computers.csv"

  #Rename the final csv file with the current date
  mv "/var/tmp/Lost_or_Stolen_Computers.csv" "/var/tmp/Lost_or_Stolen_Computers_${date}.csv"
else
  echo "No temporary file found"
fi

}

function sendMail ()
{
#Check file size is greater than zero, if so send an email with the file attached
if [ -s /var/tmp/Lost_or_Stolen_Computers_${date}.csv ]; then
  echo "Sending email with details of deleted records"
  echo "Attached are the lost or stolen computers deleted from Jamf Pro (Production)" | mailx -r jamfpro.notifications@bauerservices.co.uk -s "Jamf Pro (Production) lost or stolen computers" -a "/var/tmp/Lost_or_Stolen_Computers_${date}.csv" -- 5a6216ec.bauerahead.com@emea.teams.ms
else
  echo "No computers deleted, no need to send an email"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

startTime=$(date +"%s")
echo "Script started at: $(date +"%b %d %Y %H:%M:%S")"

echo "Obtaining all computers..."
allComputerIDs=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers" 2>/dev/null | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n)


echo "Checking for computers in the ${lostDept} department..."
echo "-----------------------------------------------------"

while read ComputerID; do
  #Getting more info about the computer
  computerName=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" 2>/dev/null | xmllint --format --xpath  "/computer/general/name"  - | awk -F'>|<' '{print $3}')

  echo "Checking $computerName with ID:${ComputerID}"
  computerDepartment=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" | xmllint --format --xpath "/computer/location/department" - | awk -F'>|<' '{print $3}')

  if [[ "$computerDepartment" == "$lostDept" ]]; then
          echo "$computerName is lost or stolen"
          echo "Deleting computer record for $computerName..."
          #Export the computer details to a file for reference
          curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" 2>/dev/null | xmllint --format --xpath  "/computer/general/name | /computer/general/serial_number | /computer/location/department" - | awk -F'>|<' '{print $3,$7,$11}' >> /var/tmp/Lost_or_Stolen_Computers.txt
          curl -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" -X DELETE | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' &>/dev/null
  fi
done < <(echo "$allComputerIDs")

finalizeCSV
sendMail

sleep 2
#Remove the temp file with results
rm -f /var/tmp/Lost_or_Stolen_Computers*

endTime=$(date +"%s")
timeDiff=$((endTime-startTime))
echo "Script completed at: $(date +"%b %d %Y %H:%M:%S"), total run time: ${timeDiff} Seconds"

exit 0
