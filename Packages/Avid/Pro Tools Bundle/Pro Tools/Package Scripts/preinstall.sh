#!/bin/bash

########################################################################
#                      Preinstall - Pro Tools 2019                     #
#################### Written by Phil Walker Nov 2019 ###################
########################################################################

#Remove any previous version of Pro Tools to allow for upgrades or fresh installs

########################################################################
#                            Variables                                 #
########################################################################

#Pro Tools app
proToolsApp="/Applications/Pro Tools.app"

########################################################################
#                         Script starts here                           #
########################################################################

#If found, remove previous version of Pro Tools
if [[ -d "$proToolsApp" ]]; then
  echo "Pro Tools already installed"
  echo "Removing currently version..."
  rm -rf "$proToolsApp"
    #re-populate variable
    proToolsApp="/Applications/Pro Tools.app"
    if [[ ! -d "$proToolsApp" ]]; then
      echo "Previous version of Pro Tools removed, proceed with install"
    else
      echo "Previous version removal FAILED!"
      exit 1
    fi
else
  echo "No existing install of Pro Tools found, proceed with install"
fi

exit 0
