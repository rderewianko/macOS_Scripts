#!/bin/bash

########################################################################
#               Check BitBar Application Status                        #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#BitBar App
BitBar="/Library/Application Support/JAMF/bitbar/BitBarDistro.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$BitBar" ]]; then
  echo "<result>Installed</result>"
else
  echo "<result>Not Installed</result>"
fi

exit 0
