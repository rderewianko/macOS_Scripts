#!/bin/bash

########################################################################
#                  Google Chrome preinstall script                     #
################## written by Phil Walker Apr 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

googleChrome="/Applications/Google Chrome.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$googleChrome" ]]; then
  echo "Cleaning up previous version of Google Chrome..."
  rm -rf "$googleChrome"
    if [[ ! -d "$googleChrome" ]]; then
      echo "Previous version removed successfully"
    else
      echo "Prevous version removal failed"
    fi
else
  echo "Google Chrome not installed, nothing to clean up"
fi

exit 0