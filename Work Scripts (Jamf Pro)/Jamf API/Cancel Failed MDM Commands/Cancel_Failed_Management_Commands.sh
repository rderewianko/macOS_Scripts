#!/bin/bash

########################################################################
#                 Cancel failed management commands                    #
################ Written by Phil Walker November 2019 ##################
########################################################################

## API Username & Password
## Note: API account must have READ and UPDATE access to:
## • Computers

########################################################################
#                            Variables                                 #
########################################################################

#API creds for connection
apiUser="API_User" #defined in the policy
apiPass="API_Password" #defined in the policy
#JSS URL (Leave off trailing slash)
jssURL="https://yourjamfprourl" #defined in the policy
#Get serial number
serialNumber=$(/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

########################################################################
#                         Script starts here                           #
########################################################################

#Check for failed management commands
failedCommands=$(curl -X GET "${jssURL}/JSSResource/computerhistory/serialnumber/${serialNumber}/subset/Commands" -H "accept: application/xml" -sku "${apiUser}:${apiPass}" | xmllint --format --xpath /computer_history/commands/failed -)
#If failed commands are found, clear them all
if [[ "$failedCommands" =~ "command" ]]; then

	#Getting the computer ID
  ComputerID=$(curl -X GET "${jssURL}/JSSResource/computers/serialnumber/$serialNumber" -H "accept: application/xml" -sku "${apiUser}:${apiPass}" | xmllint --format --xpath /computer/general/id - | awk -F '>|<' '{print $3}')

	echo "Removing failed management commands ..."

	#Clear all failed commands
  curl -X DELETE "${jssURL}/JSSResource/commandflush/computers/id/"$ComputerID"/status/Failed" -H "accept: application/xml" -sku "${apiUser}:${apiPass}" > /dev/null 2>&1
	#Allow time for commands to clear
	sleep 2

		#Re-populate variable
		failedCommands=$(curl -X GET "${jssURL}/JSSResource/computerhistory/serialnumber/${serialNumber}/subset/Commands" -H "accept: application/xml" -sku "${apiUser}:${apiPass}" | xmllint --format --xpath /computer_history/commands/failed -)

		if [[ "$failedCommands" =~ "command" ]]; then
      echo "Failed management commands found, removal FAILED!"
      exit 1
		else
			echo "All failed management commands removed"
		fi

else

	echo "No failed management commands found"

fi

exit 0
