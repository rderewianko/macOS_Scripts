#!/bin/bash

########################################################################
#             Turn Bluetooth off via management command                #
################## Written by Phil Walker July 2019 ####################
########################################################################

## API Username & Password
## Jamf Pro Server Objects
## Note: API account must have CREATE/READ/UPDATE access to:
## • Computers
## Jamf Pro Server Actions
## • Send Computer Bluetooth Command

##requires macOS 10.13.4 or later

########################################################################
#                            Variables                                 #
########################################################################

#API creds for connection
apiuser="$4" #defined in the policy
apipass="$5" #defined in the policy
#JSS URL (Leave off trailing slash)
jssurl="$6" #defined in the policy
#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get serial number
serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#Bluetooth controller power status
btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$btPowerStatus" == "0" ]] || [[ "$btPowerStatus" == "false" ]]; then

  echo "Bluetooth already turned off, nothing to do"
  exit 0

else

  echo "Turning Bluetooth off..."
  #Getting the computer ID
  ComputerID=$(curl -X GET "${jssurl}/JSSResource/computers/serialnumber/$serialNumber" -H "accept: application/xml" -sku "${apiuser}:${apipass}" | xmllint --format --xpath /computer/general/id - | awk -F '>|<' '{print $3}')

  #Send Enable Bluetooth command
  curl -X POST "${jssurl}/JSSResource/computercommands/command/SettingsDisableBluetooth/id/$ComputerID" -H "accept: application/xml" -sku "${apiuser}:${apipass}" > /dev/null 2>&1

fi

while true ; do
  #Re-populate Bluetooth controller power status variable
  btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)
   if [[ "$btPowerStatus" == "0" ]] || [[ "$btPowerStatus" == "false" ]]; then
      echo "Bluetooth now off"
      exit
   fi
done

exit 0
