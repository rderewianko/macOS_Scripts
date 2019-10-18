#!/bin/bash

########################################################################
#                      Preinstall - Pro Tools 2019                     #
#################### Written by Phil Walker Oct 2019 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#First get the Mac hostname
hostName=$(scutil --get HostName)

#Define what the external HDD should be named
proToolsHDD="/Volumes/$hostName Pro Tools Sessions"
proToolsHDDshort="$hostName Pro Tools Sessions"

########################################################################
#                         Script starts here                           #
########################################################################

#Check if the HDD with the correct name is mounted
if mount | grep "on $proToolsHDD" > /dev/null; then
  echo "Pro Tools HDD is mounted, proceed with Install"
	exit 0

else
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "External Hard Drive for Additional Content Not Found" -description "In order for ProTools 2019 to be installed an external hard drive with the correct naming convention needs to be attached.

The External drive should be formatted and named
$proToolsHDDshort " -timeout 30 -button1 "Ok" -defaultButton "1"
  echo "Pro Tools HDD not mounted, installation cannot continue"
  exit 1

fi
