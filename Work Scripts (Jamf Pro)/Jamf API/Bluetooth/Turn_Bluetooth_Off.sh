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
#                            Functions                                 #
########################################################################

function jamfHelperBTOff()
{
#jamf Helper to advise the user that Bluetooth is now off and how it can be turned back on if needed
#We DO NOT disable Bluetooth it is simply turned off if its never used/no devices are paired
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/PreferencePanes/Bluetooth.prefPane/Contents/Resources/AppIcon.icns -title "Message from Bauer IT" -heading "        Bluetooth Turned Off" -description "To improve the security of your Mac, Bluetooth has now been turned off.

If you wish to pair a device in the future please use either of the methods below:

1) Open the Self Service app, select Configuration and then select Enable Bluetooth.

2) Open System Preferences, select Bluetooth and then select Turn Bluetooth On.

" -timeout 120 -button1 "OK" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$btPowerStatus" -eq "0" ]] || [[ "$btPowerStatus" == "false" ]]; then

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
   if [[ "$btPowerStatus" -eq "0" ]] || [[ "$btPowerStatus" == "false" ]]; then
      echo "Bluetooth now off"
      jamfHelperBTOff
      exit
   fi
done

exit 0
