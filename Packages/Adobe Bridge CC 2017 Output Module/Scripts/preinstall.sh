#!/bin/bash

#######################################################################
#        Check if Bridge CC 2017 is installed (preinstall)            #
######################### written by Phil Walker ######################
#######################################################################

# Script created as part of the package to install the Output Module

########################################################################
#                            Variables                                 #
########################################################################

BridgeCC="/Applications/Adobe Bridge CC 2017/Adobe Bridge CC 2017.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [ -d "$BridgeCC" ] ; then
	echo "Adobe Bridge CC 2017 installed"
  exit 0
else
  echo "Adobe Bridge CC 2017 not installed"
  exit 1
fi
