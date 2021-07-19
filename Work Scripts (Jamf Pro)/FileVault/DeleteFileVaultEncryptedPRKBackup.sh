#!/bin/zsh

########################################################################
#                 Delete FileVault Encrypted PRK Backup                #
################### Written by Phil Walker July 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# FileVault status
fvStatus=$(fdesetup status | awk '/FileVault is/{print $3}' | tr -d .)
# FileVault encrypted PRK
encryptedPRK="/var/db/FileVaultPRK.dat"
# Encrypted PRK backup
prkBackup="/usr/local/BauerMediaGroup/FileVaultPRK/FileVaultPRK.dat"
# Jamf binary
jamfBinary="/usr/local/jamf/bin/jamf"
# Jamf Pro URL
jamfProURL=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url 2>/dev/null)

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm FileVault is enabled
if [[ "$fvStatus" == "On" ]]; then
    echo "FileVault is on"
    if [[ -f "$encryptedPRK" ]]; then
        echo "Default FileVault encrypted PRK found"
        if [[ -f "$prkBackup" ]]; then
            echo "FileVault encrypted PRK backup found"
            echo "Deleting FileVault encrypted PRK..."
            rm -f "$prkBackup" 2>/dev/null
            if [[ ! -f "$encryptedPRK" ]]; then
                echo "FileVault encrypted PRK backup succesfully deleted"
                # Submit inventory
                "$jamfBinary" recon &>/dev/null
                echo "Inventory submitted to ${jamfProURL}"
            else
                echo "Failed to delete FileVault encrypted PRK backup!"
                exit 1
            fi
        else
            echo "Backup FileVault encrypted PRK not found, nothing to do"
        fi
    else
        echo "FileVault encrypted PRK not found, no changes made"
    fi
else
    echo "FileVault is off!"
    exit 1
fi
exit 0