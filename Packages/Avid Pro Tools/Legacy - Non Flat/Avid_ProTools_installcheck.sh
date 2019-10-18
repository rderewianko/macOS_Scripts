#!/bin/sh
## InstallationCheck
##
## Not supported for flat packages.

#First get the Mac hostname
hostName=$(scutil --get ComputerName)

#Define what the external HDD should be named
AvastorHDD="/Volumes/$hostName Avastor Pro Tools Sessions"
AvastorHDDshort="$hostName Avastor Pro Tools Sessions"

#Check if the HDD with the correct name is mounted
if mount | grep "on $AvastorHDD" > /dev/null; then
        echo "Avastor HDD is mounted Proceed with Install"
		exit 0

else
    echo "Avastor HDD not mounted"
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Message from Bauer IT" -heading "External Hard Drive for Plugins Not found" -description "In order for ProTools 12 to be installed an external hard drive with the correct naming convention needs to be attached.

The External drive should be formatted and named
$AvastorHDDshort " -button1 "Ok" -defaultButton 1 -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns &

#Kill the Installer as no Avastor HDD with correct naming was found
killall Installer

exit 1
fi
