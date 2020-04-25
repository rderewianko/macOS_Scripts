#!/bin/bash

########################################################################
#            FileVault Deferral Plist - Extension Attribute            #
#################### Written by Phil Walker Apr 2020 ###################
########################################################################

# Deferral plist
deferralPlist="/usr/local/bin/FileVaultEnablement.plist"

#OS Version Short
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$osShort" -ge "15" ]]; then
    if [[ -e "$deferralPlist" ]]; then
        echo "<result>Found</result>"
    else
        echo "<result>Not Found</result>"
    fi
else
    echo "<result>N/A</result>"
fi