#!/bin/bash

########################################################################
#         Kill Jamf Remote process pre-upgrade to 10.17.0              #
############### Written by Phil Walker Nov 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

jamfRemotePID=$(ps -ef | grep -i "Jamf Remote" | grep -v grep | awk '{ print $2 }' | head -n 1)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jamfRemotePID" == "" ]]; then
        echo "Jamf Remote process not found, nothing to kill"
        exit 0
else
        kill "$jamfRemotePID"
        echo "Jamf Remote process killed!"
fi

exit 0
