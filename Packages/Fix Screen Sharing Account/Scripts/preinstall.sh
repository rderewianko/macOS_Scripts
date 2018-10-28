#!/bin/sh

########################################################################
#                   Delete casperscreensharing account                 #
#################### written by Phil Walker June 2017 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Check Directory Services for casperscreensharing Account
DSCL=$(dscl . list /Users | grep "casperscreensharing")

########################################################################
#                         Script starts here                           #
########################################################################

  echo "Checking for casperscreensharing account..."
 if [ -z "$DSCL" ]; then
  echo "Casper Screen Sharing account not found"
  exit 0
 else
  jamf deleteAccount -username casperscreensharing -deleteHomeDirectory
   echo "Casper Screen Sharing account and Home Directory deleted"
  DSCL=$(dscl . list /Users | grep "casperscreensharing")
   echo "Second check for casperscreensharing account..."
  if [ -z "$DSCL" ]; then
   echo "Casper Screen Sharing account not found"
   exit 0
  else
    dscl . delete /Users/casperscreensharing
    rm -Rf /private/var/casperscreensharing
   echo "Casper Screen Sharing account and Home Directory deleted"
   exit 0
  fi
fi
