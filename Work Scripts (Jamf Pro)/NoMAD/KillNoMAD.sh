#!/bin/bash

########################################################################
#      Kill NoMAD post successful password change to force alert       #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

NoMADPID=$(ps -ef | grep -i "NoMAD" | grep -v grep | awk '{ print $2 }' | head -n 1)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ $NoMADPID == "" ]]; then
        echo "NoMAD process not running, nothing to kill"
        exit 0
else
        kill $NoMADPID
        echo "NoMAD process killed!"
fi

exit 0
