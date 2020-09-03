#!/bin/bash

########################################################################
#           Uninstall Microsoft Office 2011 Error Reporting            #
################## Written by Phil Walker Aug 2020 #####################
########################################################################
# 32-bit applications below left behind by Office 2011 for Mac
# /Library/Application Support/Microsoft/MERP2.0/Microsoft Ship Asserts.app
# /Library/Application Support/Microsoft/MERP2.0/Microsoft Error Reporting.app

########################################################################
#                            Variables                                 #
########################################################################

legacyMERP="/Library/Application Support/Microsoft/MERP2.0"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$legacyMERP" ]]; then
    rm -rf "$legacyMERP"
    sleep 2
    if [[ ! -d "$legacyMERP" ]]; then
        echo "Legacy Microsoft Office 2011 Error Reporting uninstalled successfully"
    else
        echo "Failed to uninstall Microsoft Office 2011 Error Reporting, manual clean-up required"
        exit 1
    fi
else
    echo "Legacy Microsoft Office 2011 Error Reporting not found, nothing to do"
fi
exit 0