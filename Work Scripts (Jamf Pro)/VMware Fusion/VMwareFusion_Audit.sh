#!/bin/zsh

########################################################################
#                  VMware Fusion Serial Number Audit                   #
################### Written by Phil Walker Mar 2021  ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# VMware Fusion app
vmwareFusion="/Applications/VMware Fusion.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$vmwareFusion" ]]; then
    # Get VMware Fusion major version
    vmwareFusionVersion=$(defaults read "/Applications/VMware Fusion.app/Contents/Info" CFBundleShortVersionString | cut -c -2)
    echo "VMware Fusion ${vmwareFusionVersion} installed"
    echo "Checking all VMware software license files..."
    echo "-----------------------------------"
    # All VMware software license files found
    vmwareSoftwareLicense=$(find "/Library/Preferences/VMware Fusion" -iname "*license-fusion*" -maxdepth 1)
    for file in ${(f)vmwareSoftwareLicense}; do
        # Get the file modification date
        modifiedDate=$(cat "$file" | grep "LastModified" | awk '{print $3, $5}' | tr -d '"')
        echo "LastModified: ${modifiedDate}"
        # Get the license version
        licenseVersion=$(cat "$file" | grep -v "StartFields" | grep "LicenseVersion" | awk '{print $3}' | tr -d '"')
        echo "LicenseVersion: ${licenseVersion}"
        # Get the license edition
        licenseEdition=$(cat "$file" | grep -v "StartFields" | grep "LicenseEdition" | awk '{print $3}' | tr -d '"')
        echo "LicenseEdition: ${licenseEdition}"
        # Get the serial number
        serialNumber=$(cat "$file" | grep "Serial" | awk '{print $3}' | tr -d '"')
        echo "Serial: ${serialNumber}"
        echo "-----------------------------------"
    done
else
    echo "VMware Fusion not installed, nothing to do"
fi
exit 0