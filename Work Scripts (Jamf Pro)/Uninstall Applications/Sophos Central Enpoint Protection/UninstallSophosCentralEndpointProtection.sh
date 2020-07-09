#!/bin/bash

########################################################################
#             Uninstall Sophos Central Endpoint Protection             #
################### Written by Phil Walker June 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Sophos Endpoint App
sophosApp="/Applications/Sophos Endpoint.app"
# Sophos Device Encryption App
sophosEncryptApp="/Applications/Sophos Device Encryption.app"
# Sophos Installation Deployer
sophosInstallDeployer="/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer"

########################################################################
#                         Script starts here                           #
########################################################################

# Remove Sophos Applications and services
"$sophosInstallDeployer" --remove
sleep 3
# Check that the uninstall process was successful
if [[ ! -d "$sophosApp" ]] && [[ ! -d "$sophosEncryptApp" ]]; then
    echo "Successfully uninstalled Sophos Central Endpoint Protection"
    # Run recon to add Mac into any smart group necessary
    /usr/local/jamf/bin/jamf recon >/dev/null 2>&1 # output to policy logs not necessary
    # Check for policies. Some machines will require the user to enter their creds to issue a new recovery key
    # Sophos Endpoint will also then be reinstalled
    /usr/local/jamf/bin/jamf policy >/dev/null 2>&1 # output to policy logs not necessary
else
    echo "Uninstall process failed, disable Tamper Protection and try again"
    exit 1
fi

exit 0