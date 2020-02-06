#!/bin/bash

########################################################################
#            Adobe CS & CC Configuration Error 16 Fix                  #
################# Written by Phil Walker Feb 2018 ######################
######################## preinstall script #############################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

CS6=$(ls /Applications/ | grep -i "CS6" 2>/dev/null | wc -l)
CC=$(ls /Applications/ | grep -i "CC" 2>/dev/null | wc -l)

########################################################################
#                         Script starts here                           #
########################################################################

#Check for any CS or CC App in /Applications
if [[ "$CS6" -eq "0" ]] && [[ "$CC" -eq "0" ]] ; then
  echo "No Adobe CS6 or CC Apps found in /Applications"
  exit 1
else
  echo "Adobe CS or CC Apps found, continuing....."
  exit 0
fi
