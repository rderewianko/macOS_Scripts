#!/bin/sh

########################################################################
#        Remove BitBar ADPassword script - Mojave and above only       #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the OS version
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')
OSFull=$(sw_vers -productVersion)

#BitBar ADPassword script location
BitBarAD="/Library/Application Support/JAMF/bitbar/BitBarDistro.app/Contents/MacOS/ADPassword.1d.sh"

########################################################################
#                            Functions                                 #
########################################################################

#Double check if the policy should be run
function checkOS() {
if [[ "$OSShort" -lt "14" ]]; then
  echo "OS Version is $OSFull, nothing will be removed"
  echo "Exiting script......."
  exit 0
else
  echo "OS Version is $OSFull, checking for BitBar ADPassword script..."
fi
}

function checkADScript() {

if [[ ! -a "$BitBarAD" ]]; then
  echo "ADPassword.1d.sh not found, nothing to do"
  echo "Exiting script......."
  exit 0
else
  echo "ADPassword.1d.sh found so will be removed"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

#Check OS is 10.14 or above
checkOS
#Check ADPassword script is present
checkADScript

echo "Removing file ADPassword.1d.sh..."

#Remove ADPassword script
rm -f "$BitBarAD"

#Check removal was successful
echo "Checking removal was successful"
if [[ ! -a "$BitBarAD" ]]; then

  echo "ADPassword script deleted successfully"

else

  echo "ADPassword script removal FAILED"
  exit 1

fi

exit 0
