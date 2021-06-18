#!/bin/zsh

########################################################################
#                       Uninstall 4D Version 14                        #
################## Written by Phil Walker June 2021 ####################
########################################################################
# 32 bit app

########################################################################
#                            Variables                                 #
########################################################################

# 4D version 14
version14="/Applications/4D v14"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$version14" ]]; then
    echo "4D version 14 found"
    rm -rf "$version14"
    if [[ ! -d "$version14" ]]; then
        echo "4D version 14 uninstalled successfully"
    else
        echo "Failed to uninstall 4D version 14"
        exit 1
    fi
else
    echo "4D version 14 not found, nothing to do"
fi
exit 0