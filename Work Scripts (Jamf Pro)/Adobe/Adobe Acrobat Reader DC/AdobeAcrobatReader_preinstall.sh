#!/bin/bash

########################################################################
#      Adobe Acrobat Reader DC Self Service Policy - preinstall        #
################### Written by Phil Walker May 2020 ####################
########################################################################

# Close Adobe Reader/Adobe Acrobat Reader DC before installation

########################################################################
#                            Variables                                 #
########################################################################

adobeReaderPID=$(ps aux | grep -v grep | grep "AdobeReader\|Adobe Acrobat Reader DC" | awk '{print $2}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$adobeReaderPID" != "" ]]; then
    echo "Closing Adobe Acrobat Reader DC before installation"
    for pid in $adobeReaderPID; do
        kill "$pid" 2>/dev/null
    done
    sleep 2
    # re-populate variable to confirm the app has been closed
    adobeReaderPID=$(ps aux | grep -v grep | grep "AdobeReader\|Adobe Acrobat Reader DC" | awk '{print $2}')
    if [[ "$adobeReaderPID" == "" ]]; then
        echo "Adobe Acrobat Reader DC closed"
    else
        echo "Adobe Acrobat Reader DC still open, exiting to avoid installation failure"
        exit 1
    fi
else
    echo "Adobe Acrobat Reader DC not open"
fi

exit 0