#!/bin/zsh

########################################################################
#     Restore FileVault Encrypted PRK For Escrow Post Provisioning     #
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
    if [[ ! -f "$encryptedPRK" ]]; then
        if [[ -f "$prkBackup" ]]; then
            echo "FileVault encrypted PRK backup found"
            echo "Restoring FileVault encrypted PRK..."
            ditto "$prkBackup" "/var/db"
            if [[ -f "$encryptedPRK" ]]; then
                echo "FileVault encrypted PRK succesfully restored"
                # Submit inventory
                "$jamfBinary" recon &>/dev/null
                echo "Inventory submitted to ${jamfProURL}"
                echo "Valid PRK will be available in Jamf Pro after the SecurityInfo command has run"
            else
                echo "Failed to restore FileVault encrypted PRK!"
                exit 1
            fi
        else
            echo "Backup FileVault encrypted PRK not found"
            echo "A new FileVault PRK will need to be issued"
        fi
    else
        echo "FileVault encrypted PRK found, no requirement to restore"
    fi
else
    echo "FileVault is off!"
    exit 1
fi
exit 0