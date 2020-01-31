#!/bin/bash

########################################################################
#               Papermule InDesign CC plugin installation              #
#                   Created by Phil Walker Oct 2018                    #
###################### postinstall script ##############################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Find which versions of InDesign are installed
ADOBEINDESIGN=$(find /Applications/Adobe\ InDesign\ CC*/Scripts/startup\ scripts/ -type d -maxdepth 0 > /tmp/InDesignInstalls.txt)
#Script temp location
STARTUPSCRIPT="/usr/local/Papermule/PapermuleIDCS4XTLSupportV1.jsx"

########################################################################
#                         Script starts here                           #
########################################################################

while read LINE; do
cp -pf "$STARTUPSCRIPT" "$LINE"
echo "Copying Papermule script to $LINE..."
done < /tmp/InDesignInstalls.txt

rm -rf /tmp/InDesignInstalls.txt
rm -rf /usr/local/Papermule

exit 0
