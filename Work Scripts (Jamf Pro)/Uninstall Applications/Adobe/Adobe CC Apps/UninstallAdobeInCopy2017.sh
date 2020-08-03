#!/bin/bash

########################################################################
#                    Uninstall Adobe InCopy CC 2017                    #
#################### Written by Phil Walker June 2020 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
# App sap code
sapCode="AICY"
# App version
appVersion="12.0.0"
# InCopy 2019 Package receipt
pkgReceipt=$(pkgutil --pkgs | grep "com.adobe.Enterprise.install.609964F7-F196-4C18-9EE9-7A92585B7A83")

########################################################################
#                            Functions                                 #
########################################################################

function killInCopy ()
{
# InCopy 2017 PID
incopyPID=$(pgrep "Adobe InCopy CC 2017")
if [[ "$incopyPID" != "" ]]; then
    while [[ "$incopyPID" != "" ]]; do
        kill -9 "$incopyPID" 2>/dev/null
        sleep 2
        # re-populate variable
        incopyPID=$(pgrep "Adobe InCopy CC 2017")
    done
    echo "Adobe InCopy CC 2017 process killed"
else
    echo "Adobe InCopy CC 2017 not open"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$pkgReceipt" != "" ]] && [[ -d "/Applications/Adobe InCopy CC 2019" ]]; then
    if [[ -d "/Applications/Adobe InCopy CC 2017" ]]; then
        echo "Adobe InCopy CC 2017 found"
        # If open kill the InCopy 2017 process
        killInCopy
        sleep 5
        # Uninstall InCopy 2017
        echo "Uninstalling Adobe InCopy CC 2017..."
        "$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$appVersion" --platform=osx10-64 --deleteUserPreferences=false >/dev/null 2>&1
        if [[ "$?" == "0" ]]; then
            sleep 2
            # Sometimes the directory is left behind. If found, remove it
            while [[ -e "/Applications/Adobe InCopy CC 2017" ]]; do
                echo "Adobe InCopy CC 2017 directory found after uninstall command completed"
                echo "Deleting Adobe InCopy CC 2017 directory..."
                rm -rf "/Applications/Adobe InCopy CC 2017" >/dev/null 2>&1
                sleep 2
            done
            # Remove package receipt
            pkgutil --forget "com.adobe.Enterprise.install.0A83B18F-FB8F-43C8-BD41-8A44297A8FA8" >/dev/null 2>&1
            if [[ ! -e "/Applications/Adobe InCopy CC 2017" ]]; then
                echo "Adobe InCopy CC 2017 uninstalled successfully"
            else
                echo "Failed to uninstall Adobe InCopy CC 2017"
                exit 1
            fi
        else
            echo "Adobe uninstaller failed, removing the app directory anyway"
            # If the Adobe uninstall method fails then remove the directory anyway
            rm -rf "/Applications/Adobe InCopy CC 2017" >/dev/null 2>&1
            # Remove package receipt
            pkgutil --forget "com.adobe.Enterprise.install.0A83B18F-FB8F-43C8-BD41-8A44297A8FA8" >/dev/null 2>&1
            if [[ ! -e "/Applications/Adobe InCopy CC 2017" ]]; then
                echo "Adobe InCopy CC 2017 uninstalled successfully"
            else
                echo "Failed to uninstall Adobe InCopy CC 2017"
                exit 1
            fi
        fi
    else
        echo "Adobe InCopy CC 2017 not found, nothing to do"
    fi
else
    # Package receipt for Adobe InCopy CC 2019 not found so do nothing
    echo "Adobe InCopy CC 2019 failed to install successfully"
    echo "Adobe InCopy CC 2017 has not been uninstalled"
fi

exit 0