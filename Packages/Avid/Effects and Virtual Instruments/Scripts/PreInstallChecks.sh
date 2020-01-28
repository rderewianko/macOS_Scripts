#!/bin/bash

########################################################################
#      Pre-Install Checks - Effects and Virtual Instrument Bundles     #
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
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "External Hard Drive for Additional Content Not Found" -description "In order for the Effects and Virtual Instrument Bundle to be installed an external hard drive with the correct naming convention needs to be attached.

The external drive should be formatted and named
${proToolsHDDshort} " -timeout 30 -button1 "Ok" -defaultButton "1"
}

########################################################################
#                         Script starts here                           #
########################################################################

#Check if the HDD with the correct name is mounted
if mount | grep "on $proToolsHDD" > /dev/null; then

  echo "Pro Tools HDD is mounted, calling install policy..."
  /usr/local/bin/jamf policy -event install_pt_effects_bundle

else

  echo "Pro Tools HDD not mounted, installation cannot continue"
  externalHDDHelper
  exit 1

fi

exit 0
