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
#                            Functions                                 #
########################################################################

function postCheck()
{

localGoogleChrome="/Applications/Google Chrome.app"

if [[ ! -d "$googleChrome" ]]; then

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

if [[ -d "$googleChrome" ]]; then

  echo "Cleaning up old version of Google Chrome..."

  rm -rf "$googleChrome"

  postCheck

else
  echo "Google Chrome not installed, nothing to clean up"
  exit 0

fi

exit 0
