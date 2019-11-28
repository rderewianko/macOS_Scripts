#!/bin/bash

########################################################################
#                      Preflight - Pro Tools 2019                      #
#################### Written by Phil Walker Oct 2019 ###################
########################################################################

#Check that an external hard drive is connected and named correctly
#WKSxxxxx Pro Tools Sessions

#Remove any previous version of Pro Tools to allow for upgrades or fresh installs

########################################################################
#                            Variables                                 #
########################################################################

#First get the Mac hostname
hostName=$(scutil --get HostName)

#Define what the external HDD should be named
proToolsHDD="/Volumes/$hostName Pro Tools Sessions"
proToolsHDDshort="$hostName Pro Tools Sessions"

#Pro Tools app
proToolsApp="/Applications/Pro Tools.app"

########################################################################
#                            Functions                                 #
########################################################################

function removalFailureHelper ()
{
#jamf Helper to advise that the previous version could not be removed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "Removal of Previous Pro Tools Version" -description "An existing version of Pro Tools has been found but could not be removed

Please contact the IT Service Desk on 0345 058 4444 for assistance" -timeout 30 -button1 "Ok" -defaultButton "1"
}

function externalHDDHelper ()
{
#jamf Helper to advise that an external disk for sessions and virtual instrument content has not been found
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Problem\ Reporter.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "External Hard Drive for Additional Content Not Found" -description "In order for Pro Tools to be installed an external hard drive with the correct naming convention needs to be attached.

The External drive should be formatted and named
$proToolsHDDshort " -timeout 30 -button1 "Ok" -defaultButton "1"
}

function removePreviousVersion ()
{
#If found, remove previous version of Pro Tools
if [[ -d "$proToolsApp" ]]; then
  echo "Pro Tools already installed"
  echo "Removing currently version..."
  rm -rf "$proToolsApp"
    #re-populate variable
    proToolsApp="/Applications/Pro Tools.app"
    if [[ ! -d "$proToolsApp" ]]; then
      echo "Previous version of Pro Tools removed, proceed with install"
    else
      removalFailureHelper
      echo "Previous version removal FAILED!"
      exit 1
    fi
else
  echo "No existing install of Pro Tools found, proceed with install"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Check if the HDD with the correct name is mounted
if mount | grep "on $proToolsHDD" > /dev/null; then

  echo "Pro Tools HDD is mounted, checking for a previous version..."
  removePreviousVersion

else

  externalHDDHelper
  echo "Pro Tools HDD not mounted, installation cannot continue"
  exit 1

fi

exit 0
