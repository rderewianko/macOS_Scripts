#!/bin/zsh

########################################################################
#              Download and Install Microsoft Applications             #
########################################################################

# Credit to Written William Smith (Professional Services Engineer @Jamf bill@talkingmoose.net
# https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a
# Edited by Phil Walker Jan 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Microsoft fwlink (permalink) product ID e.g. "2009112" for Office 365 Business Pro
linkID="$4"
# 525133 - Office 2019 for Mac SKUless download (aka Office 365)
# 2009112 - Office 365 for Mac Business Pro SKUless download (aka Office 365 with Teams)
# 830196 - AutoUpdate download
# 2093438 - Edge (Enterprise Stable)
# 2093294 - Edge (Enterprise Beta)
# 2093292 - Edge (Enterprise Dev)
# 525135 - Excel 2019 SKUless download
# 869655 - InTune Company Portal download
# 823060 - OneDrive download
# 820886 - OneNote download
# 525137 - Outlook 2019 SKUless download
# 525136 - PowerPoint 2019 SKUless download
# 868963 - Remote Desktop
# 800050 - SharePoint Plugin download
# 832978 - Skype for Business download
# 869428 - Teams
# 525134 - Word 2019 SKUless download
# sha256 Checksum e.g. "67b1e8e036c575782b1c9188dd48fa94d9eabcb81947c8632fd4acac7b01644b"
sha256Checksum="$5" # This is not required. Install will start with no value in this parameter.
# Package Name
pkgName="$6"
############ Variables for Jamf Pro Parameters - End ###################
# Full fwlink URL
fullURL="https://go.microsoft.com/fwlink/?linkid=$linkID"

########################################################################
#                         Script starts here                           #
########################################################################

# Create a temporary working directory
echo "Creating temporary directory for the download"
tempDirectory=$(/usr/bin/mktemp -d "/private/tmp/MicrosoftAppDownload.XXXXXX")

# Download the installer package and name using the value found in parameter 6
echo "Downloading package $pkgName.pkg"
/usr/bin/curl --location --silent "$fullURL" -o "${tempDirectory}/${pkgName}.pkg"
# Check if the download completed
commandResult="$?"
if [[ "$commandResult" -ne "0" ]]; then
    echo "Failed to download the package, exiting..."
    exit 1
fi

# Checksum the download
downloadChecksum=$(/usr/bin/shasum -a 256 "${tempDirectory}/${pkgName}.pkg" | /usr/bin/awk '{ print $1 }')
echo "Checksum for downloaded package: $downloadChecksum"
# Install the package if checksum validates
if [ "$sha256Checksum" = "$downloadChecksum" ] || [ "$sha256Checksum" = "" ]; then
	echo "Checksum verified. Installing package $pkgName.pkg"
	/usr/sbin/installer -pkg "${tempDirectory}/${pkgName}.pkg" -target /
else
	echo "Checksum failed. Recalculate the SHA 256 checksum and try again. Or download may not be valid."
	exit 1
fi

# Remove the temporary working directory when done
/bin/rm -Rf "$tempDirectory"
echo "Deleting temporary directory '$tempDirectory' and its contents"
if [[ ! -d "$tempDirectory" ]]; then
    echo "Temporary directory deleted"
else
    echo "Failed to delete the temporary directory"
fi

exit 0