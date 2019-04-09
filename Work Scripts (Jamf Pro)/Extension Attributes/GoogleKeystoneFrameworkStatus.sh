#!/bin/bash

########################################################################
#                Google Keystone Framework Status EA                   #
################## written by Phil Walker Mar 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

Keystone_Framework=$(ls /Applications/Google\ Chrome.app/Contents/Versions/*/Google\ Chrome\ Framework.framework/Versions/A/Frameworks/ | grep -i "keystone")

########################################################################
#                         Script starts here                           #
########################################################################

#echo "DEBUG: $Keystone_Framework"

if [[ "$Keystone_Framework" == "" ]]; then
    echo "<result>Framework Not Present</result>"
else
    echo "<result>Framework Present</result>"
fi

exit 0
