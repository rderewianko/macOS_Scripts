#!/bin/bash

########################################################################
#                 Install Adobe Premiere Elements 2020                 #
################## Written by Phil Walker July 2020 ####################
########################################################################
# Script required due to how crap Adobe are

########################################################################
#                            Variables                                 #
########################################################################

# Temp location of package
premiereElements2020="/usr/local/AdobePremiereElements2020"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$premiereElements2020" ]]; then
    /usr/bin/unzip -q "${premiereElements2020}/UK_Adobe_Premiere_Elements_2020.pkg.zip" -d "$premiereElements2020"
    if [[ -e "${premiereElements2020}/UK_Adobe_Premiere_Elements_2020.pkg" ]]; then
        echo "Adobe Premiere Elements 2020 package found"
        /usr/sbin/installer -pkg "${premiereElements2020}/UK_Adobe_Premiere_Elements_2020.pkg" -target /
        sleep 3
        if [[ -d "/Applications/Adobe Premiere Elements 2020" ]]; then
            rm -rf "$premiereElements2020"
        else
            echo "Adobe Premiere Elements 2020 failed to install"
            exit 1
        fi
    else
        echo "Adobe Premiere Elements 2020 package not found!"
        exit 1
    fi
else
    echo "Temp directory for package not found!"
fi

exit 0