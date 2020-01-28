#!/bin/bash

########################################################################
#          Preinstall - Effects and Virtual Instrument Bundle          #
#################### Written by Phil Walker Nov 2019 ###################
########################################################################

#Check that an external hard drive is connected and named correctly
#WKSxxxxx Pro Tools Sessions

########################################################################
#                            Variables                                 #
########################################################################

#First get the Mac hostname
hostName=$(scutil --get HostName)

#Define what the external HDD should be named
proToolsHDD="/Volumes/$hostName Pro Tools Sessions"
proToolsHDDshort="$hostName Pro Tools Sessions"

########################################################################
#                            Functions                                 #
########################################################################

function externalHDDHelper ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -description "In order for the Effects and Virtual Instrument Bundle to be installed an external hard drive with the correct naming convention needs to be attached.

The external drive should be formatted and named
${proToolsHDDshort} " -timeout 30 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

#Kill download in progress Jamf Helper message, if required
killall jamfHelper

#Check if the HDD with the correct name is mounted
if mount | grep "on $proToolsHDD" > /dev/null; then

  echo "Pro Tools HDD is mounted, continuing with install..."

else

  echo "Pro Tools HDD not mounted, installation cannot continue"
  externalHDDHelper
  exit 1

fi

exit 0
