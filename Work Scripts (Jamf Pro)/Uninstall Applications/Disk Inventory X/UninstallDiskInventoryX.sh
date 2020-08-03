#!/bin/bash

########################################################################
#                     Uninstall Disk Inventory X                       #
################## Written by Phil Walker July 2020 ####################
########################################################################
# 32 bit app that is no longer in use

########################################################################
#                            Variables                                 #
########################################################################

# Disk Inventory X Application
diskInventoryX="/Users/admin/Applications/Disk Inventory X.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$diskInventoryX" ]]; then
    echo "Disk Inventory X found"
    rm -rf "$diskInventoryX"
    if [[ ! -d "$diskInventoryX" ]]; then
        echo "Disk Inventory X uninstalled successfully"
    else
        echo "Failed to uninstall Disk Inventory X"
        exit 1
    fi
else
    echo "Disk Inventory X not found, nothing to do"
fi

exit 0