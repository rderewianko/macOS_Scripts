#!/bin/bash

########################################################################
#                  Google Chrome preinstall script                     #
################## written by Phil Walker Apr 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

CHROME="/Applications/Google Chrome.app"

########################################################################
#                            Functions                                 #
########################################################################

function postCheck()
{

CHROME="/Applications/Google Chrome.app"

if [[ ! -d "$CHROME" ]]; then

  echo "Google Chrome removed successfully"
  exit 0

else

  echo "Google Chrome removal failed"
  exit 1

fi

}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$CHROME" ]]; then

  echo "Cleaning up old version of Google Chrome..."

  rm -rf "$CHROME"

  postCheck

else
  echo "Google Chrome not installed, nothing to clean up"
  exit 0

fi

exit 0
