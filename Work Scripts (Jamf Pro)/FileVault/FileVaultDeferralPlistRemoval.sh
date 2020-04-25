#!/bin/bash

########################################################################
#    Delete FileVault Deferral Plist (macOS 10.15+ Pro Tools Only)     #
#################### Written by Phil Walker Apr 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# FileVault status
fileVault=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)

# Deferral plist
deferralPlist="/usr/local/bin/FileVaultEnablement.plist"

#OS Version Full and Short
osFull=$(sw_vers -productVersion)
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$osShort" -ge "15" ]]; then
    echo "Mac running $osFull"
        if [[ "$fileVault" == "FileVault is On." ]] && [[ -e "$deferralPlist" ]]; then
            echo "FileVault is on, deleting the deferral plist..."
            rm -f "$deferralPlist"
                if [[ ! -e "$deferralPlist" ]]; then
                    echo "Deferral plist deleted"
                else
                    echo "Deferral plist found, manual cleanup required"
                    exit 1
                fi
        else
            echo "Nothing to do"
        fi
else
    echo "Mac running ${osFull}, exiting"
    exit 0
fi

exit 0
