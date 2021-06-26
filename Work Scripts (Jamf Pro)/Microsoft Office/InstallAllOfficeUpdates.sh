#!/bin/bash

########################################################################
#         Microsoft AutoUpdate - Install All Available Updates         #
################### Written by Phil Walker May 2020 ####################
########################################################################

# Original content from pbowden https://github.com/pbowden-msft/msupdatehelper
# Minor amendments made to best fit our use case

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# MAU command line tool
mauCLI="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
# Application IDs - Could be changed to Jamf Pro Parameters
wordAppID="MSWD2019"
excelAppID="XCEL2019"
pptAppID="PPT32019"
outlookAppID="OPIM2019"
onenoteAppID="ONMC2019"
sfbAppID="MSFB16"
mrdAppID="MSRD10"
edgeAppID="EDGE01"
teamsAppID="TEAM01"
onedriveAppID="ONDR18"
#cpAppID="IMCP01"
#defenderAppID="WDAV00"
#mauAppID="MSau04"

# Date and time
datetime=$(date +%d-%m-%Y\ %T)

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

# Check if MAU 3.18 or later command-line updates are available
function checkMAUInstall () 
{
if [ ! -e "$mauCLI" ]; then
	echo "ERROR: MAU 3.18 or later is required!"
	exit 1
fi
}

# Check if we are allowed to send Apple Events to MAU
function checkAppleEvents () 
{
mauResult=$(runAsUser "$mauCLI" --config 2>/dev/null | grep "No result returned from Update Assistant")
if [[ "$mauResult" = *"No result returned from Update Assistant"* ]]; then
	echo "ERROR: Cannot send Apple Events to MAU. Check privacy settings!"
	exit 1
fi
}

# Check if MAU is up-to-date
function checkMAUUpdate () 
{
# Download URL for Microsoft AutoUpdater
officeURL="https://go.microsoft.com/fwlink/?linkid=830196"
# Generate the download URL for newest AutoUpdater
downloadURL=$(curl "$officeURL" -s -L -I -o /dev/null -w '%{url_effective}')
# Version available to download
pkgVersion=$(echo "$downloadURL" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
# Current version installed
installedPkgVersion=$(defaults read "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/Info.plist" CFBundleVersion)
if [[ "$pkgVersion" != "$installedPkgVersion" ]]; then
	echo "Installing Microsoft AutoUpdate ${pkgVersion}..."
	# Download update package
	curl -s -Lo /var/tmp/mauUpdater.pkg "$downloadURL"
	# Install package
	installer -pkg /var/tmp/mauUpdater.pkg -target / >/dev/null 2>&1
	# Clean-up
	rm -rf /var/tmp/mauUpdater.pkg
    # Wait before checking for updates
	sleep 120
fi
}

# Check whether its safe to close Excel because it has no open unsaved documents
function closeExcel () 
{
excelState=$(runAsUser pgrep "Microsoft Excel")
if [ ! "$excelState" == "" ]; then
	dirtyDocs=$(runAsUser defaults read com.microsoft.Excel NumTotalBookDirty)
	if [ "$dirtyDocs" == "0" ]; then
		echo "$datetime"
		echo "Closing Excel as no unsaved documents are open"
		sudo -u "$loggedInUser" pkill -HUP "Microsoft Excel"
	fi
fi
}

# Flush any existing MAU sessions
function flushDaemon () 
{
runAsUser defaults write com.microsoft.autoupdate.fba ForceDisableMerp -bool TRUE
runAsUser pkill -HUP "Microsoft Update Assistant"
}

# Call 'msupdate' and update the target applications
function installUpdates () 
{
echo "$datetime"
###### Use relevant method from below depending on requirements ######
# Install updates for apps listed and suppress output
#sudo -u "$loggedInUser" "$mauCLI" --install --apps "$1" --wait 600 >/dev/null 2>&1
# Install updates for apps listed
#sudo -u "$loggedInUser" "$mauCLI" --install --apps "$1" --wait 600
# Install all updates available
runAsUser "$mauCLI" --install --wait 600
}

########################################################################
#                         Script starts here                           #
########################################################################

echo "Started - ${datetime}"
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "No user currently logged in, exiting..."
    echo "Finished - ${datetime}"
    exit 0
else
    echo "$loggedInUser is logged in"
fi
checkMAUInstall
flushDaemon
checkAppleEvents
checkMAUUpdate
flushDaemon
closeExcel
###### Below method must match the one from the function ######
#installUpdates "$wordAppID $excelAppID $pptAppID $outlookAppID $onenoteAppID $sfbAppID $mrdAppID $edgeAppID $teamsAppID $onedriveAppID"
installUpdates
echo "Finished - ${datetime}"
exit 0