#!/bin/bash

########################################################################
#                   FileVault Status (On or Off)                       #
########################################################################

FV2Stat=$(fdesetup status | awk '{print $3}' | sed 's/\.//g')

echo "<result>$FV2Stat</result>"

exit 0
