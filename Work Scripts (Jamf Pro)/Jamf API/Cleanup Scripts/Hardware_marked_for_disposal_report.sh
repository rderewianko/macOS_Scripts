#!/bin/bash

########################################################################
#        Create and send report of hardware marked for disposal        #
################## Written by Phil Walker July 2019 ####################
########################################################################

## API Username & Password
## Note: API account must have READ access to:
## • Computers

## Report to be used to check serial numbers in ABM, release the device
## if required, before deleting the computer record

########################################################################
#                            Variables                                 #
########################################################################

#API creds for connection
apiuser="API_User"
apipass="API_Password"

#JSS URL (Leave off trailing slash)
jssurl="https://yourjamfprourl"

#Jamf Pro decomission department
disposalDept="YourDisposalDepartment"

#Date
date=$(date +"%d-%m-%Y")

########################################################################
#                            Functions                                 #
########################################################################

function finalizeCSV ()
{

if [[ -f "/var/tmp/Computers_For_Disposal.txt" ]]; then
  echo -e "Finalizing csv file...\n"

  #Use paste to join all data into a final csv file
  paste -s -d'\n' "/var/tmp/Computers_For_Disposal.txt" >> "/var/tmp/Computers_For_Disposal.csv"

  #Rename the final csv file with the current date
  mv "/var/tmp/Computers_For_Disposal.csv" "/var/tmp/Computers_For_Disposal_${date}.csv"
else
  echo "No temporary file found"
fi

}

function sendMail ()
{
#Check file size is greater than zero, if so send an email with the file attached
if [ -s /var/tmp/Computers_For_Disposal_${date}.csv ]; then
  echo "Sending email with details of Macs marked for disposal"
  echo "Attached are the computers marked for disposal in Jamf Pro (Production)" | mailx -r jamfpro.notifications@bauerservices.co.uk -s "Jamf Pro (Production) computers marked for disposal" -a "/var/tmp/Computers_For_Disposal_${date}.csv" -- 5a6216ec.bauerahead.com@emea.teams.ms
else
  echo "No computers marked for disposal, no need to send an email"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

startTime=$(date +"%s")
echo "Script started at: $(date +"%b %d %Y %H:%M:%S")"

echo "Obtaining all computers..."
allComputerIDs=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers" 2>/dev/null | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n)


echo "Checking for computers in the ${disposalDept} department..."
echo "--------------------------------------------------------"

while read ComputerID; do
  #Getting more info about the computer
  computerName=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" 2>/dev/null | xmllint --format --xpath  "/computer/general/name"  - | awk -F'>|<' '{print $3}')

  echo "Checking $computerName with ID:${ComputerID}"
  computerDepartment=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" | xmllint --format --xpath "/computer/location/department" - | awk -F'>|<' '{print $3}')

  if [[ "$computerDepartment" == "$disposalDept" ]]; then
          echo "$computerName has been marked for disposal"
          echo "Deleting computer record for $computerName..."
          #Export the computer details to a file
          curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" 2>/dev/null | xmllint --format --xpath  "/computer/general/name | /computer/general/serial_number | /computer/location/department | /computer/hardware/model" - | awk -F'>|<' '{print $3,$7,$11,$15}' >> /var/tmp/Computers_For_Disposal.txt
          curl -sfku "${apiuser}:${apipass}" "${jssurl}/JSSResource/computers/id/$ComputerID" -X DELETE | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' &>/dev/null
  fi
done < <(echo "$allComputerIDs")

finalizeCSV
sendMail

sleep 2
#Remove the temp file with results
rm -f /var/tmp/Computers_For_Disposal*

endTime=$(date +"%s")
timeDiff=$((endTime-startTime))
echo "Script completed at: $(date +"%b %d %Y %H:%M:%S"), total run time: ${timeDiff} Seconds"

exit 0
