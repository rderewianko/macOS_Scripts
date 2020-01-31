#!/bin/bash

########################################################################
#               Install Papermule Adobe InDesign plugin                #
#                   Written by Phil Walker Jan 2020                    #
###################### postinstall script ##############################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Find which versions of InDesign are installed
adobeInDesign=$(find /Applications/Adobe\ InDesign*/Scripts/startup\ scripts/ -type d -maxdepth 0 > /tmp/InDesignInstalls.txt)
#Script temp location
startupScript="/usr/local/Papermule/PapermuleIDCS4XTLSupportV1.jsx"

########################################################################
#                            Functions                                 #
########################################################################

function cleanUp ()
{
#Clean up temporary files and directories
if [[ ! -f "/tmp/InDesignInstalls.txt" ]] && [[ ! -d "/usr/local/Papermule" ]]; then
  echo "All temporary files and directories removed"
else
  echo "Clean up failed, manual clean up required"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

while read line; do
cp -pf "$startupScript" "$line"
echo "Copied Papermule script to $line..."
done < /tmp/InDesignInstalls.txt

rm -f /tmp/InDesignInstalls.txt
rm -rf /usr/local/Papermule

cleanUp

exit 0
