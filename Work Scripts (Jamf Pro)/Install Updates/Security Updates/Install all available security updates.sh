#!/bin/bash

########################################################################
#          Install all recommended security updates (Apple CDN)        #
######## Written by Suleyman Twana and Phil Walker July/Aug 2019 #######
########################################################################

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperUpdatefailed ()
{
HELPER=$(
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/ReportPanic.app/Contents/Resources/ProblemReporter.icns -title "Message from Bauer IT" -heading "The security updates have failed to install" -alignHeading center -description "Something has gone wrong!.

Please contact IT Service Desk on 0345 058 4444 and report the security updates' failure." -button1 "OK"
)
}

function cleanUp()
{
# Remove the security update packages from the Mac
find /Library/Updates/ -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \; 2>/dev/null

# Remove the security update packages list from /tmp
rm -f /tmp/SU.txt
}

########################################################################
#                         Script starts here                           #
########################################################################

# Check Apple CDN for latest macOS updates and download recommended ones
softwareupdate --download --recommended
echo "Recommended updates are checked"

# Get the path to the updates folder and isolate all required update packages
InstallerPath=$(find /Library/Updates -type f -name "*iTunes*" -or -name "*MobileDeviceSU*" -or -name "*Safari*" -or -name "*Sec*" | grep -i ".pkg" > /tmp/SU.txt)

# Read through the update packages list and install them all
while read -r line || [[ -n "${line}" ]]; do
		echo "${line}"
	installer -pkg "${line}" -target /
done < /tmp/SU.txt

# Check for available updates again
Updates=$(softwareupdate -l | grep -i "Security Update" | awk 'NR==2 {print $1,$2}')

# Do a final Check to see if all security updates have been successfully installed
if [[ "${Updates}" != "Security Update" ]]; then
	echo "All recommended updates have been installed"

# Clean up update packages and temp file
	cleanUp

# If security updates are still outstanding it indicates the updates have failed
else
	if [[ "${Updates}" == "Security Update" ]]; then
		echo "Something has gone wrong and no updates are installed!"

# Inform the user that the updates have failed and they need to contact IT Service Desk
		jamfHelperUpdatefailed

# Clean up update packages and temp file
		cleanUp

	fi
fi

exit 0
