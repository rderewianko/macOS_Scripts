#!/bin/bash

########################################################################
#         Install Bauer PDF Preset and PreFlight Settings              #
################ Written by Phil Walker Mar 2018 #######################
########################################################################

# Postinstall script

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
echo "Current user is $LoggedInUser"

#Folder/File location
tmp="/usr/local/Adobe/"
PreFlight="/usr/local/Adobe/PreFlight"

########################################################################
#                            Functions                                 #
########################################################################

function copySettings() {
#Copy the PDF Preset and PreFlight settings for the logged in user
if [[ -d /Users/$LoggedInUser/Library/Application\ Support/Adobe/Adobe\ PDF/ ]]; then
  echo "Copying PDF and PreFlight settings..."
    cp /usr/local/Adobe/Bauer\ Ready\ for\ Press.joboptions /Users/$LoggedInUser/Library/Application\ Support/Adobe/Adobe\ PDF/Settings/
    chown $LoggedInUser:"BAUER-UK\Domain Users" /Users/$LoggedInUser/Library/Application\ Support/Adobe/Adobe\ PDF/Settings/Bauer\ Ready\ for\ Press.joboptions
    cp -R $PreFlight /Users/$LoggedInUser/Library/Application\ Support/Adobe/
    chown -R $LoggedInUser:"BAUER-UK\Domain Users" /Users/$LoggedInUser/Library/Application\ Support/Adobe/PreFlight
  else
    echo "InDesign has never been launched by $LoggedInUser so no preferences will be copied"
    exit 1
fi
}

function checkSettings() {
#Check that the settings have been copied successfully
if [[ -e /Users/$LoggedInUser/Library/Application\ Support/Adobe/Adobe\ PDF/Settings/Bauer\ Ready\ for\ Press.joboptions &&
  -e /Users/$LoggedInUser/Library/Application\ Support/Adobe/PreFlight/ ]]; then
    echo "PDF and PreFlight settings now available for $LoggedInUser"
  else
    echo "Copy failed, please run the installation again"
    exit 1
fi
}

function cleanUp() {
#Cleanup installation files
rm -R "$tmp"
if [ ! -e $tmp ] ; then
  echo "Cleanup complete"
else
  echo "Cleanup failed - Delete the folder /usr/local/Adobe manually"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################


copySettings
sleep 2
checkSettings

cleanUp

exit 0
