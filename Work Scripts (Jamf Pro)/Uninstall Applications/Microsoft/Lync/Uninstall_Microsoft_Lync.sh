#!/bin/bash

########################################################################
#                      Uninstall Microsoft Lync                        #
################## Written by Phil Walker Oct 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Microsoft Lync Application
msLync="/Applications/Microsoft Lync.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$msLync" ]]; then
    echo "Microsoft Lync found"
    rm -rf "$msLync"
    if [[ ! -d "$msLync" ]]; then
        echo "Microsoft Lync uninstalled successfully"
    else
        echo "Failed to uninstall Microsoft Lync"
        exit 1
    fi
else
    echo "Microsoft Lync not found, nothing to do"
fi
exit 0