#!/bin/zsh

########################################################################
#    Remove the Adobe CC Desktop App Directory Before Reinstall        #
################### written by Phil Walker Nov 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Creative Cloud Directory
ccDesktop="/Applications/Utilities/Adobe Creative Cloud"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$ccDesktop" ]]; then
    pkill -9 "Creative Cloud Helper"
    pkill -9 "Creative Cloud"
    sleep 5
    echo "Removing the CC Desktop app directory before reinstall..."
    rm -rf "$ccDesktop"
    if [[ ! -d "$ccDesktop" ]]; then
        echo "Adobe Creative Cloud Desktop directory removed successfully"
    else
        echo "Failed to remove the Adobe Creative Cloud Desktop directory, exiting!"
        exit 1
    fi
else
    echo "Adobe Creative Cloud Desktop directory not found, nothing to do"
fi
exit 0