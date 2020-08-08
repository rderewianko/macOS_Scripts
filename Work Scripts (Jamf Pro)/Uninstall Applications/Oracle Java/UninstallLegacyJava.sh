#!/bin/bash

########################################################################
#                Uninstall Legacy Java - Oracle JDK 6                  #
################## Written by Phil Walker Aug 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Legacy Java
legacyJava="/Library/Java/JavaVirtualMachines/1.6.0.jdk"

########################################################################
#                         Script starts here                           #
########################################################################

# If legacy Java is installed, uninstall it!
if [[ -d "$legacyJava" ]]; then
    rm -rf "$legacyJava"
    sleep 2
    if [[ ! -d "$legacyJava" ]]; then
        echo "Legacy Java removed successfully"
    else
        echo "Failed to remove Legacy Java, manual clean-up required"
        exit 1
    fi
else
    echo "Legacy Java not found"
fi

exit 0